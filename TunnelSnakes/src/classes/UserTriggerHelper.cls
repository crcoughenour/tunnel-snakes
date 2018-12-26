public without sharing class UserTriggerHelper 
{
    public static void UserAfterInsert(List<User> passUserList)
    {
    	//create a map whose key is the contactID, and whose value is a user object
		Map<id, User> userMap = new Map<Id, User>();
		
		//get the record type id of coverage member
		Id covMembId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Coverage Member').getRecordTypeId();
		
		//get a list of all the groups we will be using
		List<CollaborationGroup> groupList = [SELECT Id, Name FROM CollaborationGroup];
		
		//make a map for all the groups, with the key being the name, and the value being its id
		Map<String, Id> groupMap = new Map<String, Id>();
		
		//the list that will be added at the end containing all the group members
		List<CollaborationGroupMember> collMemberList = new List<CollaborationGroupMember>();
		//afflictionPickValues[currentInt].getValue();
		
		//a list of all user contactIds
		List<Id> userContactIdList = new List<Id>();
		
		//make a map with the 
		
		//populate the group map
		for(CollaborationGroup curGroup : groupList)
		{
			groupMap.put(curGroup.Name, curGroup.Id);
		}
		
		
		//populate the user contact id list, and the userMap
		for(User curUser : passUserList)
		{
			if(curUser.contactId != null)
			{
				userContactIdList.add(curUser.contactId);
				userMap.put(curUser.contactId, curUser);
			}
		}
		
		
		//get all the contact records that we will be using
		List<Contact> conList = [SELECT Id, Affliction__c, RecordTypeId FROM Contact WHERE Id IN :userContactIdList];
		
		//populate the wrapper class
		for(Contact curCont : conList)
		{
			//only use contacts that are of the type we want(Coverage Member)
			//System.debug(covMembId + ' == ' + curCont.RecordTypeId);
			if(covMembId == curCont.RecordTypeId)
			{
				//get a list of all the groups they need to be added to
				List<String> afflictionList = curCont.Affliction__c.split(';');
				//add them to the list
				for(String curAff : afflictionList)
				{
					//create the new junction objects
					collMemberList.add(new CollaborationGroupMember(CollaborationGroupId = groupMap.get(curAff), MemberId = userMap.get(curCont.Id).Id));
				}
			}
		}
		
		try
		{
            //System.debug(collMemberList);
			insert collMemberList;
		}
		catch(DMLException e)
		{
			throw e;
		}
    }
}