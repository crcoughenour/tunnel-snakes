/* Developer: Stuart Zeiger
 * Created on: 12-22-18
 * Description: test class for the PartnerAppointsmentsController class
 */

@isTest
public with sharing class PartnerAppointmentsTest 
{
    
    
    @isTest public static void testWorking()
    {
    	
    	Contact testPatient = new Contact();
    	Contact testDoctor = new Contact();
    	Appointment__c testAppointment = new Appointment__c();
    	
    	Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coverage_Member' AND sObjectType = 'Contact' LIMIT 1].Id;
    	testPatient.FirstName = 'TestPatientFirst';
    	testPatient.LastName = 'TestPatientLast';
    	testPatient.email = 'zeigerstuart@gmail.com';
    	testPatient.RecordTypeId = recTypeId;
    	
    	
    	recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Professional' AND sObjectType = 'Contact' LIMIT 1].Id;
    	testDoctor.FirstName = 'TestDoctorFirst';
    	testDoctor.LastName = 'TestDoctorLast';
    	testDoctor.email = 'zeigerstuart@gmail.com';
    	testDoctor.RecordTypeId = recTypeId;
    	testDoctor.Appointment_Length_Minutes__c = 25;
    	
    	insert testPatient;
    	insert testDoctor;
    	
    	testAppointment.Coverage_Member__c = testPatient.id;
    	testAppointment.Professional__c = testDoctor.id;
    	testAppointment.Appointment_Type__c = 'Treatment';
    	testAppointment.Reason_For_Visit__c = 'Cancer';
    	testAppointment.Start_Time__c = DateTime.now().addDays(10);
    	
    	insert testAppointment;
    	
    	PartnerAppointmentsController testClass = new PartnerAppointmentsController();
    	
    	testClass.appointmentWrapperList[0].setToDelete = true;
    	
    	testClass.deleteSelectedAppointments();
    	try
    	{
    		List<Appointment__c> tempList = new List<Appointment__c>([SELECT id FROM Appointment__c WHERE id = :testAppointment.id]);
    		//fail test if this is reached
    		System.assert(tempList.size() == 0);
    	}
    	catch(Exception e)
    	{
    		//System.assertEquals(e.getTypeName(), 'QueryException');
    		System.assert(false);
    	}
    }
    
    @isTest public static void testWorkingNoDelete()
    {
    	
    	Contact testPatient = new Contact();
    	Contact testDoctor = new Contact();
    	Appointment__c testAppointment = new Appointment__c();
    	
    	Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coverage_Member' AND sObjectType = 'Contact' LIMIT 1].Id;
    	testPatient.FirstName = 'TestPatientFirst';
    	testPatient.LastName = 'TestPatientLast';
    	testPatient.email = 'zeigerstuart@gmail.com';
    	testPatient.RecordTypeId = recTypeId;
    	
    	
    	recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Professional' AND sObjectType = 'Contact' LIMIT 1].Id;
    	testDoctor.FirstName = 'TestDoctorFirst';
    	testDoctor.LastName = 'TestDoctorLast';
    	testDoctor.email = 'zeigerstuart@gmail.com';
    	testDoctor.RecordTypeId = recTypeId;
    	testDoctor.Appointment_Length_Minutes__c = 25;
    	
    	insert testPatient;
    	insert testDoctor;
    	
    	testAppointment.Coverage_Member__c = testPatient.id;
    	testAppointment.Professional__c = testDoctor.id;
    	testAppointment.Appointment_Type__c = 'Treatment';
    	testAppointment.Reason_For_Visit__c = 'Cancer';
    	testAppointment.Start_Time__c = DateTime.now().addDays(10);
    	
    	insert testAppointment;
    	
    	PartnerAppointmentsController testClass = new PartnerAppointmentsController();
    	
    	testClass.appointmentWrapperList[0].setToDelete = false;
    	
    	testClass.deleteSelectedAppointments();
    	try
    	{
    		List<Appointment__c> tempList = new List<Appointment__c>([SELECT id FROM Appointment__c WHERE id = :testAppointment.id]);
    		//fail test if this is reached
    		System.assert(tempList.size() == 1);
    	}
    	catch(Exception e)
    	{
    		//System.assertEquals(e.getTypeName(), 'QueryException');
    		System.assert(false);
    	}
    }
}