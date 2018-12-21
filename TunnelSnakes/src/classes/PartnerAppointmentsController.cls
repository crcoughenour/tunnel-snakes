/* Developer: Stuart Zeiger
 * Created on: 12-20-18
 * Description: controller class for the PartnerAppointments Visualforce page.
 * 	used to provide all nessecary information that will be required for the doctor, or nurse,
 *  to manage/cancel all upcoming appointments
 */

public with sharing class PartnerAppointmentsController 
{
    public List<Appointment__c> appointmentList{get; set;}
    public Map<id, Contact> covMemberMap {get; set;}
    public List<Boolean> appBoolList {get; set;}
    public List<Contact> doctorList {get;}
    public Map<Id, String> doctorMap {get;}
    private DateTime currentDateTime;
    
    
    public PartnerAppointmentsController()
    {
    	currentDateTime = System.now();
    	try
    	{
    		//Set<Id> tempIdSet;
    		
    		//get all doctors that the current user has access to
    			//necessary incase the user is a nurse who is in charge of multiple doctors scheduling
	    	doctorList = [SELECT Id, Name FROM Contact];
	    	
	    	//fill a map with keys = doctor's id, values = doctor's name
	    	for(Contact con : doctorList)
	    	{
	    		//tempIdSet.add(con.Id);
	    		doctorMap.add(con.Id, con.Name);
	    	}
	    	
	    	//get all appointments that have not occured yet, and that are for the doctors previously gotten
	    	appointmentList = [SELECT Id, Appointment_Length__c, Appointment_Type__c, 
	    					   Coverage_Member__c, Professional__c, Reason_For_Visit__c, 
	    					   Start_Time__c, Description__c FROM Appointment__c 
	    					   WHERE ((Start_Time__c > :currentDateTime) and Professional__c IN :doctorMap.keySet())
	    					   ORDER BY Start_Time__c];
	    					   
		    //make the list of boolean values the same size as appointmentList and populate it with all falses
    		for(Integer i = 0; i < appointmentList.size(); i++)
    		{
    			appBoolList.add(false);
    		}
    	}
    	catch(QueryException e)
    	{
    		throw e;
    	}
    }
    
    
    //function to delete all the appointments that were selected in the VF page
    public PageReference deleteSelectedAppointments()
    {
    	//list that needs to be deleted
    	List<Appointment__c> deleteList = new List<Appointment__c>();
    	
    	//build the list that will be deleted
    	for(Integer i = 0; i < appointmentList.size(); i++)
    	{
    		//if the appointment has been selected, then add it to the delete list
    		if(appBoolList[i])
    		{
    			deleteList.add(appointmentList[i]);
    		}
    	}
    	
    	//if the delete list contains any records, DML that sucker
    	if(deleteList.size() > 0)
    	{
    		delete deleteList;
    	}
    	return null;
    }
}