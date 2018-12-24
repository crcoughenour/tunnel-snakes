/* Developer: Stuart Zeiger
 * Created on: 12-20-18
 * Description: controller class for the PartnerAppointments Visualforce page.
 * 	used to provide all nessecary information that will be required for the doctor, or nurse,
 *  to manage/cancel all upcoming appointments
 */

public with sharing class PartnerAppointmentsController 
{
    private List<Appointment__c> appointmentList;
    //public Map<id, Contact> covMemberMap {get; set;}
    //public List<Boolean> appBoolList {get; set;}
    private List<Contact> doctorList;
    private Map<Id, String> doctorMap;
    public List<AppointmentWrapper> appointmentWrapperList {get; private set;}
    private DateTime currentDateTime;
    
    
    public PartnerAppointmentsController()
    {
    	currentDateTime = System.now();
        doctorMap = new Map<Id, String>();
	    //appBoolList = new List<Boolean>();
	    appointmentWrapperList = new List<AppointmentWrapper>();
        
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
	    		doctorMap.put(con.Id, con.Name);
	    	}
	    	
	    	//get all appointments that have not occured yet, and that are for the doctors previously gotten
	    	appointmentList = [SELECT Id, Appointment_Length__c, Appointment_Type__c, 
	    					   Coverage_Member__c, Professional__c, Reason_For_Visit__c, 
	    					   Start_Time__c, Description__c, Patient_Name__c, Doctor_Name__c FROM Appointment__c 
	    					   WHERE ((Start_Time__c > :currentDateTime) and Professional__c IN :doctorMap.keySet())
	    					   ORDER BY Start_Time__c];
	    					   
		    //make the list of boolean values the same size as appointmentList and populate it with all falses
    		for(Integer i = 0; i < appointmentList.size(); i++)
    		{
    			//appBoolList.add(false);
    			appointmentWrapperList.add(new AppointmentWrapper(appointmentList[i], false));
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
    	for(Integer i = 0; i < AppointmentWrapperList.size(); i++)
    	{
    		//if the appointment has been selected, then add it to the delete list
    		if(AppointmentWrapperList[i].setToDelete)
    		{
    			deleteList.add(AppointmentWrapperList[i].appointment);
    			AppointmentWrapperList.remove(i);
    			i--;
    		}
    	}
    	
    	//if the delete list contains any records, DML that sucker
    		//also email all the patients that their appointment has been canceled
    	if(deleteList.size() > 0)
    	{
    		try
    		{
    			//delete the records, will this clear out local records? if so need to move below emailing
    			delete deleteList;
    			
    			//make a list of the emails to be sent
    			List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    			
    			//get the template that I want to use so I will have a letterhead
    			//Id emailTempID = [SELECT Id FROM EmailTemplate WHERE name = 'Blank_With_Letterhead' LIMIT 1].Id;
    			//Id emailTempID = PartnerAppointmentsControllerHelper.getEmailTemplateID('Blank_With_Letterhead');
    			
    			
    			//make an email for all the appointments being deleted and add them to the email list
    			for(Appointment__c curApp : deleteList)
    			{
    				//make a new email
    				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    				
    				//set the template for the email
    				//mail.setTemplateId(emailTempID);
    				
    				//get the patients email address from the Helper class
    				mail.setToAddresses(new String[] {PartnerAppointmentsControllerHelper.getPatientEmail(curApp.Coverage_Member__c)});
    				
    				mail.setSubject('Appointment Cancelled');
    				
    				String bodyText = 'Dear ' + curApp.Patient_Name__c + ',\n\nYour appointment with ' 
    								  + curApp.Doctor_Name__c + ' has been cancelled.\n\nSorry for the inconvienance,\nSouthern Heart';
    				
    				mail.setPlainTextBody(bodyText);
    				//mail.setHtmlBody(bodyText);
    				emailList.add(mail);
    			}
    			
    			//bulk send all of the emails at once
    			Messaging.sendEmail(emailList);
    		}
    		catch(DMLException e)
    		{
    			throw e;
    		}
    	}
    	return null;
    }
    
    
    class AppointmentWrapper
    {
    	public Appointment__c appointment {get; set;}
    	public Boolean setToDelete {get; set;}
    	
    	public AppointmentWrapper(Appointment__c appointment, Boolean setToDelete)
    	{
    		this.appointment = appointment;
    		this.setToDelete = setToDelete;
    	}
    }
}