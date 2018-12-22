/* Developer: Cody Coughenour
* Purpose: Tests for the FindDoctorController class
* Last Modified Date: 12/20/2018
*/
@isTest
private class FindDoctorTest {

	@isTest
	//Verifies that the string is being dynamically built correctly
    static void searchDoctorTestCorrectQueryString() {
    	FindDoctorController fdc = new FindDoctorController();
        String queryString;
        
        fdc.selectedSex = 'Male';
        fdc.selectedLanguage = 'Spanish';
        fdc.selectedSpecialty = 'Heart Failure';
        
        queryString = fdc.searchDoctors();
        
        System.assertEquals('SELECT Id, FirstName, LastName, Sex__c, Languages__c, Location__c, Specialties__c' +
        					' FROM Contact WHERE Sex__c = \'Male\' AND Languages__c includes \'Spanish\'' +
        					' AND Specialties__c includes \'Heart Failure\'', queryString);
        
    }
}