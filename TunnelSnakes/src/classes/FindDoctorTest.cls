/* Developer: Cody Coughenour
* Purpose: Tests for the FindDoctorController class
* Last Modified Date: 12/25/2018
*/
@isTest
private class FindDoctorTest {

    
    //Dr Mantis Toboggan
    //Contact doctor = [SELECT id, LastName, mailingLatitude, mailingLongitude 
    //                      FROM Contact WHERE LastName = 'Toboggan' LIMIT 1];
    //                      
    //Reva Ture
    //Contact coverageMember = [SELECT id, LastName, mailingLatitude, mailingLongitude 
    //                          FROM Contact WHERE LastName = 'Ture' LIMIT 1];
    
	@isTest(SeeAllData=true)
    static void searchDoctorTest() {

        User u = [SELECT Id, LastName, ContactID FROM User WHERE LastName = 'Ture' LIMIT 1];

        System.runAs(u) {

            FindDoctorController fdc = new FindDoctorController();
           
            fdc.selectedSex = 'No Preference';
            fdc.selectedLanguage = 'English';
            fdc.selectedSpecialty = 'Cancer';
            fdc.maxDistance = '20';

            fdc.searchDoctors();
        }
        

    }
    
    @isTest
    static void searchAvailableAppointmentsTest() {
    	FindDoctorController fdc = new FindDoctorController();
    	
    	Contact doctor = new Contact(
    		lastName = 'Who', Appointment_Length_Minutes__c = 60,
    		Workdays__c = 'Monday;Tuesday;Thursday', 
    		Work_Hours__c = '8:00;9:00;10:00;12:00;13:00;14:00',
    		recordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professional').getRecordTypeId());
    		
		insert doctor;
		
		Contact coverageMember = new Contact(
			lastName = 'Coveredman',
			recordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Coverage Member').getRecordTypeId());
    	
    	insert coverageMember;
    	
    	Appointment__c booked = new Appointment__c(
    		Start_Time__c = DateTime.newInstance(2018,12,25,8,0,0),
    		Professional__c = doctor.id, 
    		Coverage_Member__c = coverageMember.id,
    		Appointment_Type__c = 'Lab Test',
    		Reason_For_Visit__c = 'Cancer');
    		
		insert booked;
    	
    	fdc.selectedDate = Date.newInstance(2018,12,25);
    	fdc.selectedDoctor = doctor;
    	
    	fdc.searchAvailableAppointments();
		
	}
}