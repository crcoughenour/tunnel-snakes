/* Developer: Stuart Zeiger
 * Created on: 12-22-18
 * Description: test data factory class to build randomly generated test data
 */
public with sharing class TestDataFactory 
{
	//NOT DONE!!!! I REPEAT!!!! NOT DONE!!!!!
	public static List<Appointment__c> getAppoinmentList(Integer numAppEach, Integer numDoctors)
	{
		List<Appointment__c> appList = new List<Appointment__c>();
		List<Contact> profList = new List<Contact>();
		List<Contact> patList = new List<Contact>();
		
		for(Integer i = 0; i < numDoctors; i++)
		{
			
			for(Integer j = 0; j < NumAppEach; j++)
			{
				
			}
		}
		
		return appList;
	}
	
	//will return a list of doctors of size numProf, THEY WILL NOT BE ADDED INTO THE DATABASE
	//added fields: firstName, lastName,  Sex__c, Languages__c, Specialties__c, Work_Hours__c(random, non-continuous),
		//Workdays__c(random, non-continuous), Appointment_Length_Minutes__c([MIN_BOUND, MAX_BOUND))
	public static List<Contact> getDoctorList(Integer numProf)
	{
		//bounds for the doctors appointment length in minutes
		final Integer MIN_BOUND = 15;
		final Integer MAX_BOUND = 45;
		//each added dr will have their index appended to both names
		String fName = 'FirstName';
		String lName = 'LastName';
		
		
		Schema.DescribeFieldResult fieldResult = Contact.Languages__c.getDescribe();
		List<Schema.PicklistEntry> langPickValues = fieldResult.getPicklistValues();
		
		fieldResult = Contact.Specialties__c.getDescribe();
		List<Schema.PicklistEntry> specPickValues = fieldResult.getPicklistValues();
		
		fieldResult = Contact.Sex__c.getDescribe();
		List<Schema.PicklistEntry> sexPickValues = fieldResult.getPicklistValues();
		
		fieldResult = Contact.Work_Hours__c.getDescribe();
		List<Schema.PicklistEntry> hoursPickValues = fieldResult.getPicklistValues();
		
		fieldResult = Contact.Workdays__c.getDescribe();
		List<Schema.PicklistEntry> daysPickValues = fieldResult.getPicklistValues();
		
		
		
		
		List<Contact> profList = new List<Contact>();
		
		//myTask.RecordTypeId =[Select Id,SobjectType,Name 
		//			          From RecordType 
		//			          WHERE Name ='Professional' and SobjectType ='Contact'  limit 1].Id;
		
		for(Integer i = 0; i < numProf; i++)
		{
			Contact newDoc = new Contact();
			newDoc.firstName = fName + i;
			newDoc.lastName = lName + i;
			
			
			//set random number of languages for the doctor
			Set<Integer> assignedValue = new Set<Integer>();
			//loop to populate as many picklist values as random
			for(Integer j = 0; j < Utility.randomNumber(1, langPickValues.size()); j++)
			{
				//get a random index for the list of picklist values
				Integer currentInt = Utility.randomNumber(langPickValues.size());
				
				//if the we haven't added that value yet, add it
				if(!assignedValue.contains(currentInt))
				{
					//if the new doctor hasn't gotten any values assigned, assign one
					if(newDoc.Languages__c == null)
					{
						newDoc.Languages__c = langPickValues[currentInt].getValue();
						
					}
					//if the new doctor already has values, append the new value to the end
					else
					{
						newDoc.Languages__c += ';' + langPickValues[currentInt].getValue();
					}
					assignedValue.add(currentInt);
				}
				//if the values has been added, roll back changes for this iteration
				else
				{
					j--;
				}
			}
			
			//set random number of Specialties for the doctor
			assignedValue = new Set<Integer>();
			//loop to populate as many picklist values as random
			for(Integer j = 0; j < Utility.randomNumber(1,specPickValues.size()); j++)
			{
				//get a random index for the list of picklist values
				Integer currentInt = Utility.randomNumber(specPickValues.size());
				
				//if the we haven't added that value yet, add it
				if(!assignedValue.contains(currentInt))
				{
					//if the new doctor hasn't gotten any values assigned, assign one
					if(newDoc.Specialties__c == null)
					{
						newDoc.Specialties__c = specPickValues[currentInt].getValue();
						
					}
					//if the new doctor already has values, append the new value to the end
					else
					{
						newDoc.Specialties__c += ';' + specPickValues[currentInt].getValue();
					}
					assignedValue.add(currentInt);
				}
				//if the values has been added, roll back changes for this iteration
				else
				{
					j--;
				}
			}
			
			
			//set random number of Work_Hours__c for the doctor
			assignedValue = new Set<Integer>();
			//loop to populate as many picklist values as random
			for(Integer j = 0; j < Utility.randomNumber(1, hoursPickValues.size()); j++)
			{
				//get a random index for the list of picklist values
				Integer currentInt = Utility.randomNumber(hoursPickValues.size());
				
				//if the we haven't added that value yet, add it
				if(!assignedValue.contains(currentInt))
				{
					//if the new doctor hasn't gotten any values assigned, assign one
					if(newDoc.Work_Hours__c == null)
					{
						newDoc.Work_Hours__c = hoursPickValues[currentInt].getValue();
						
					}
					//if the new doctor already has values, append the new value to the end
					else
					{
						newDoc.Work_Hours__c += ';' + hoursPickValues[currentInt].getValue();
					}
					assignedValue.add(currentInt);
				}
				//if the values has been added, roll back changes for this iteration
				else
				{
					j--;
				}
			}
			
			
			//set random number of Workdays__c for the doctor
			assignedValue = new Set<Integer>();
			//loop to populate as many picklist values as random
			for(Integer j = 0; j < Utility.randomNumber(1, daysPickValues.size()); j++)
			{
				//get a random index for the list of picklist values
				Integer currentInt = Utility.randomNumber(daysPickValues.size());
				
				//if the we haven't added that value yet, add it
				if(!assignedValue.contains(currentInt))
				{
					//if the new doctor hasn't gotten any values assigned, assign one
					if(newDoc.Workdays__c == null)
					{
						newDoc.Workdays__c = daysPickValues[currentInt].getValue();
						
					}
					//if the new doctor already has values, append the new value to the end
					else
					{
						newDoc.Workdays__c += ';' + daysPickValues[currentInt].getValue();
					}
					assignedValue.add(currentInt);
				}
				//if the values has been added, roll back changes for this iteration
				else
				{
					j--;
				}
			}
			
			//assign the doctor a sex
			newDoc.Sex__c = sexPickValues[Utility.randomNumber(sexPickValues.size())].getValue();
			
			//assign the doctor's appointment length
			newDoc.Appointment_Length_Minutes__c = Utility.randomNumber(MIN_BOUND, MAX_BOUND);
			
			
			profList.add(newDoc);
		}
		
		return profList;
	}
}