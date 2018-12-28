public without sharing class ContactTriggerHelper 
{
    public static void ContactAfterUpdate(Map<Id, Contact> oldConMap, Map<Id, Contact> newConMap)
    {
    	//get a list of all the groups we will be using
		List<CollaborationGroup> groupList = [SELECT Id, Name FROM CollaborationGroup];
		
		//make a map for all the groups, with the key being the name, and the value being its id
		Map<String, Id> groupMap = new Map<String, Id>();
		
		//the list that will be added at the end containing all the group members
		List<CollaborationGroupMember> collMemberList = new List<CollaborationGroupMember>();
		
		
		//map of the users that are getting put into a group
			//key is the contactID, value is the user object
		Map<Id, User> userMap = new Map<Id, User>();
		
		//get a list of all the users that are linked to one of these contacts
		List<User> userList = [SELECT id, contactId FROM User WHERE contactId IN :newConMap.keySet()];
		
		//populate the user map
		for(User curUser : userList)
		{
			userMap.put(curUser.ContactId, curUser);
		}
		
		//populate the group map
		for(CollaborationGroup curGroup : groupList)
		{
			groupMap.put(curGroup.Name, curGroup.Id);
		}
		
		//build the junction objects to put the user's into the groups
		for(Id curID : newConMap.keySet())
		{
			//only work if the contact has a user account
			if(userMap.containsKey(curID))
			{
				//since it is an update I don't think this is needed?
				if(oldConMap.containsKey(curID) && newConMap.containsKey(curID))
				{
					//only run this if the afflictions have been updated
					if(oldConMap.get(curID).Affliction__c != newConMap.get(curID).Affliction__c)
					{
						Set<String> oldAffSet;
						List<String> newAffList;
						
						//get a set of the old afflictions to test against to know which of the afflictions are new
						if(oldConMap.get(curID).Affliction__c != null)
						{
							oldAffSet = new Set<String>(oldConMap.get(curID).Affliction__c.split(';'));
						}
						else
						{
							oldAffSet = new Set<String>();
						}
						
						//get the list of the new afflictions
						if(newConMap.get(curID).Affliction__c != null)
						{
							newAffList = newConMap.get(curID).Affliction__c.split(';');
						}
						else
						{
							newAffList = new List<String>();
						}
						
						
						//check on all the new afflictions
						for(String curAff : newAffList)
						{
							//if the current affliction in the list is new, do this!
							if(!oldAffSet.contains(curAff))
							{
								//add the new object to the list that will be inserted
								collMemberList.add(new CollaborationGroupMember(CollaborationGroupId = groupMap.get(curAff), MemberId = userMap.get(curID).Id));
							}
						}
					}
				}
			}
		}
		
		try
		{
			insert collMemberList;
		}
		catch(DMLException e)
		{
			throw e;
		}
    }
}