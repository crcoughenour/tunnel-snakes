/* Developer: Cody Coughenour
* Purpose: Handles requests from Visualforce Page for searching
* for a doctor with whom to schedule an appointment.
* Last Modified Date: 12/23/2018
*/

public class FindDoctorController {
    
    //sObjects and sObject Collections
    public Contact selectedDoctor {get;set;}
    public List<Contact> doctorsToShow {get;set;}
    public List<TimeWrapper> availableTimes {get;set;}
    public List<Appointment__c> bookedAppointments {get;set;}
    public Appointment__c appointmentToSave {get;set;}

    
    //doctor search variables
    public String selectedSex {get;set;}
    public String selectedLanguage {get;set;}
    public String customerLat {get;set;}
    public String customerLong {get;set;}
    public String maxDistance {get;set;}
    public String selectedSpecialty {get;set;}
    
    //appointment search variables
    public Date selectedDate {get;set;}
    public ID selectedDoctorID {get;set;}
    
    //appointment save variables
    public String appointmentType {get;set;}
    public String appointmentReason {get;set;}
    public ID currentCustomerID {get;set;}
    public String selectedStartTime {get;set;}
    
    //display booleans
    public Boolean displayAppointmentTable {get;set;}
    public Boolean showNext {get;set;}
    public Boolean showPrev {get;set;}
    
    
    {
    	selectedDoctor = new Contact();
    	doctorsToShow = new List<Contact>();
    	availableTimes = new List<TimeWrapper>();
    	bookedAppointments = new List<Appointment__c>(); 
    	appointmentToSave = new Appointment__c();
    	
    	//get related customer object from context user 
    	ID userID = userInfo.getUserId();
    	currentCustomerID = [SELECT Id, ContactID FROM User Where Id = :userID].contactID;
    }
    
    //set list of doctors based on filter criteria
    public void searchDoctors() {
    	String queryStringSelect = 'SELECT Id, FirstName, LastName, Sex__c, Languages__c, Location__c, Specialties__c';
    	String queryStringFrom = ' FROM Contact';
    	String queryStringWhere = ' WHERE ';
    	Integer numberOfFilters = 0;
    	
    	//dynamically add Sex of Doctor preference
    	if (selectedSex != 'No Preference') {
    		queryStringWhere += 'Sex__c = \'' + selectedSex +'\'';
    		NumberOfFilters++;
    	}
    	
    	//dynamically add Language of Doctor preference
    	if (numberOfFilters > 0) {
    		queryStringWhere += ' AND';
			NumberOfFilters++;
    	}
    	queryStringWhere += ' Languages__c includes (\'' + selectedLanguage + '\')';
    	
    	//dynamically add Specialty preference
    	if (numberOfFilters > 0) {
			queryStringWhere += ' AND';
    		NumberOfFilters++;			
		}
		queryStringWhere += ' Specialties__c includes (\'' + selectedSpecialty + '\')';
    	
    	//dynamically add Location preference
    	
    	if (numberOfFilters > 0) {
			queryStringWhere += ' AND';
    		NumberOfFilters++;			
		}
    	queryStringWhere += ' DISTANCE(Location__c, GEOLOCATION(' 
    		+ String.valueOf(customerLat)+','+String.valueOf(customerLong)+'), \'mi\') < ' + maxDistance;
    		
		NumberOfFilters++;
		
    system.debug(queryStringSelect + queryStringFrom + queryStringWhere);
    doctorsToShow = Database.query(queryStringSelect + queryStringFrom + queryStringWhere);
    	
    }
    
    //Find all available appointments for a given doctor
    public void searchAvailableAppointments() {
    	DateTime selectedDateTime = selectedDate;
    	selectedDoctor = [SELECT Id, Work_Hours__c, Workdays__c, Appointment_Length_Minutes__c
    					  FROM Contact WHERE Id =:selectedDoctorID];

    	bookedAppointments = [SELECT Id, Appointment_Length__c, Start_Time__c, Professional__c
    						  FROM Appointment__c
    						  WHERE Start_Time__c >= :selectedDateTime
    						  AND Professional__c = :selectedDoctorID];
	  
		List<DateTime> bookedAppointmentDateTimes = new List<DateTime>();
		for (Appointment__c thisAppt: bookedAppointments) {
			bookedAppointmentDateTimes.add(thisAppt.Start_Time__c);
		}
		
		List<String> workHours = new List<String>();
		workHours.addAll(selectedDoctor.Work_Hours__c.split(';'));
		
		List<String> workDays = new List<String>();
		workDays.addAll(selectedDoctor.Workdays__c.split(';'));
		
		//Build list of possible appointment times
    	Boolean appointmentOverlap = false;
		DateTime potentialDateTime = selectedDateTime;
        Integer i = 0;
		if(workDays.contains(selectedDateTime.format('EEEE'))) {
			while(potentialDateTime < selectedDateTime.addDays(1)) {
				//if the doctor works at this hour
				if (workHours.contains(potentialDateTime.hour()+':00')) {
					//and an appointment does not overlap
					for (DateTime dt: bookedAppointmentDateTimes) {
                        if (dt == potentialDateTime)  {
							appointmentOverlap = true;
						}
					}
					if (appointmentOverlap != true) {
						availableTimes.add(new TimeWrapper(potentialDateTime));
					}
				}
				potentialDateTime = potentialDateTime.addMinutes(selectedDoctor.Appointment_Length_Minutes__c.intValue());
				//system.debug(potentialDateTime);
				appointmentOverlap = false;
			}
            system.debug(availableTimes);
		}
    }
    
    
    public void selectAppointment() {
    	appointmentToSave.Coverage_Member__c = currentCustomerID;
    	appointmentToSave.Professional__c = selectedDoctorID;
    	appointmentToSave.Start_Time__c = DateTime.parse(selectedStartTime);
    	//show another element to enter more information
    }
    
    public void saveAppointment() {
    	appointmentToSave.Appointment_Type__c = appointmentType;
    	appointmentToSave.Reason_For_Visit__c = appointmentReason;
    	insert appointmentToSave;
    }
    
    public class TimeWrapper {
    	public DateTime dt {get;set;}
    	
    	public TimeWrapper(DateTime dt) {
    		this.dt = dt;
    	}
    }
}