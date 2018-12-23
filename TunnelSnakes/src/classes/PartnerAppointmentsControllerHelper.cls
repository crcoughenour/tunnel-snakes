public without sharing class PartnerAppointmentsControllerHelper 
{
    public static String getPatientEmail(Id patientID)
    {
    	return [SELECT Email FROM Contact WHERE ID = :patientID].Email;
    }
    
    //not used
    public static Id getEmailTemplateID(String tempName)
    {
    	return [SELECT Id FROM EmailTemplate WHERE name = :tempName LIMIT 1].Id;
    }
}