/* Developer: Cody Coughenour
* Purpose: Handles requests from Visualforce Page for searching
* for a doctor with whom to schedule an appointment.
* Last Modified Date: 12/20/2018
*/

public class FindDoctorController {
    
    //sObjects and sObject Collections
    public Contact selectedDoctor {get;set;}
    public List<Contact> doctorsToShow {get;set;}
    public List<DateTime> availableTimes {get;set;}
    public List<Appointment__c> bookedAppointments {get;set;}
    
    //doctor search variables
    public String selectedSex {get;set;}
    public String selectedLanguage {get;set;}
    public String customerLat {get;set;}
    public String customerLong {get;set;}
    public String MaxDistance {get;set;}
    public String selectedSpecialty {get;set;}
    
    //appointment search variables
    public Date selectedDate {get;set;}
    
    //display booleans
    public Boolean displayAppointmentTable {get;set;}
    public Boolean showNext {get;set;}
    public Boolean showPrev {get;set;}
    
    {
    	selectedDoctor = new Contact();
    	doctorsToShow = new List<Contact>();
    	availableTimes = new List<DateTime>();
    	bookedAppointments = new List<Appointment__c>();    	
    }
    
    //set list of doctors based on filter criteria
    public static void searchDoctors() {
    	String queryStringSelect = 'SELECT Id, FirstName, LastName, Sex__c, Languages__c, Location__c, Specialties__c';
    	String queryStringFrom = ' FROM Contact';
    	String queryStringWhere = ' WHERE ';
    	Integer numberOfFilters = 0;
    	
    	//dynamically add Sex of Doctor preference
    	if (selectedSex != 'No Preference') {
    		queryStringWhere += 'Sex__c = ' + selectedSex;
    		NumberOfFilters++;
    	}
    	
    	//dynamically add Language of Doctor preference
    	if (numberOfFilters > 0) {
    		queryStringWhere += ' AND';
    	}
    	queryStringWhere += ' Languages__c includes ' + selectedLanguage;
    	
    	//dynamically add Specialty preference
    	if (numberOfFilters > 0) {
			queryStringWhere += ' AND';
		}
		queryStringWhere += ' Specialties__c includes ' + selectedSpecialty;
    	
    	//dynamically add Location preference
    	if (numberOfFilters > 0) {
			queryStringWhere += ' AND';
		}
    	queryStringWhere += 'DISTANCE(Location__c, GEOLOCATION(' 
    		+ String.valueOf(customerLat)+','+String.valueOf(customerLong)+'), "mi") < ' + maxDistance;	
    		
    	doctorsToShow = Database.query(queryStringSelect + queryStringFrom + queryStringWhere);
    }
    
    //Find all available appointments for a given doctor
    public static void searchAvailableAppointments() {
    	DateTime selectedDateTime = selectedDate;
    	ID DoctorID = selectedDoctor.Id;
    	bookedAppointments = [SELECT Id, Appointment_Length__c, Start_Time__c, Professional__c
    						  FROM Appointment__c
    						  WHERE Start_Time__c >= :selectedDateTime
    						  AND Professional__c = :selectedDoctorID];
	  
		List<DateTime> appointmentDateTimes = new List<DateTime>();
		for (Appointment__c thisAppt: bookedAppointments) {
			appointmentDateTimes.add(thisAppt.Start_Time__c);
		}
		
		List<String> workHours = new List<String>();
		workHours.addAll(selectedDoctor.workHours__c.split(';'));
		
		//TODO: Check that the doctor works that day
		
		//Build list of possible appointments
		DateTime copySelectedDateTime = selectedDateTime;
		Boolean appointmentOverlap = false;
		while(copySelectedDateTime < TOMORROW()) {
			//if the doctor works at this hour
			if (workHours.contains(i+':00')) {
				//and an appointment does not overlap
				for (DateTime dt: appointmentDateTimes) {
					if (dt <= copySelectedDateTime && dt.addMinutes(selectedDoctor.Appointment_Length_Minutes__c) >= copySelectedDateTime) {
						appointmentOverlap = true;
					}
				}
				if (appointmentOverlap != true) {
					availableTimes.add(copySelectedDateTime);			
				}
			}
			copySelectedDateTime.addMinutes(selectedDoctor.Appointment_Length_Minutes__c);
			appointmentOverlap = false;
		}
    	
    }
    
}