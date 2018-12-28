/* Developer: Cody Coughenour
* Purpose: Handles requests from Visualforce Page for searching
* for a doctor with whom to schedule an appointment.
* Last Modified Date: 12/27/2018 
*/

public class FindDoctorController {
    
    //sObjects and sObject Collections
    public Contact currentCustomer {get;set;}
    public Contact selectedDoctor {get;set;}
    public List<Contact> doctorsToShow {get;set;}
    public List<TimeWrapper> availableTimes {get;set;}
    public List<Appointment__c> bookedAppointments {get;set;}
    public Account familyAccount {get;set;}
    public List<Contact> dependents {get;set;}
    public Appointment__c appointmentToSave {get;set;}
    public EmailTemplate blankTemplate {get;set;}

    //global picklists
    public List<SelectOption> specOptions {get;set;}
    public List<SelectOption> langOptions {get;set;}
    
    //doctor search variables
    public String selectedSex {get;set;}
    public String selectedLanguage {get;set;}
    public String maxDistance {get;set;}
    public String selectedSpecialty {get;set;}
    
    //appointment search variables
    public Date selectedDate {get;set;}
    public ID selectedDoctorID {get;set;}
    
    //appointment save variables
    public String appointmentType {get;set;}
    public ID currentCustomerID {get;set;}
    public Contact selectedDependent {get;set;}
    public ID selectedDependentID {get;set;}
    public String selectedStartTime {get;set;}
    
    //display booleans
    public Boolean displayCriteria {get;set;}
    public Boolean displayDoctorTable {get;set;}
    public Boolean displayAppointmentTable {get;set;}
    public Boolean displayAppointmentInfo {get;set;}
    public Boolean displayConfirmation {get;set;}
    public Boolean showNext {get;set;}
    public Boolean showPrev {get;set;}
    
    {
        selectedDoctor = new Contact();
        doctorsToShow = new List<Contact>();
        availableTimes = new List<TimeWrapper>();
        bookedAppointments = new List<Appointment__c>(); 
        appointmentToSave = new Appointment__c();
        blankTemplate = new EmailTemplate();
        
        //get picklist values
        Schema.DescribeFieldResult fieldResult = Contact.Languages__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        langOptions = new List<SelectOption>();
        
        for(Schema.PicklistEntry pEntry: entries) {
            if (pEntry.isActive()) {
                langOptions.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }
        
        fieldResult = Contact.Specialties__c.getDescribe();
        entries.clear();
        entries = fieldResult.getPicklistValues();
        specOptions = new List<SelectOption>();
        
        for(Schema.PicklistEntry pEntry: entries) {
            if (pEntry.isActive()) {
                specOptions.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }
        
        //default display values
        displayCriteria = true;
        displayAppointmentTable = false;
        displayDoctorTable = false;
        displayAppointmentInfo = false;
        displayConfirmation = false;
        
        //get related customer object from context user 
        ID userID = userInfo.getUserId();
        currentCustomerID = [SELECT Id, ContactID FROM User Where Id = :userID].contactID;
        if (currentCustomerID != null) {
            currentCustomer = [SELECT Id, Name, MailingLatitude, MailingLongitude, Social_Security_Number__c, Email FROM Contact WHERE Id = :currentCustomerID];
        }
        system.debug(currentCustomerID);
        familyAccount = [SELECT Id FROM Account WHERE Primary_Social_Security_Number__c = :currentCustomer.Social_Security_Number__c];
        dependents = [SELECT Id, Name, AccountID FROM Contact WHERE AccountID = :familyAccount.Id ];
    }
    
    //set list of doctors based on filter criteria
    public void searchDoctors() {
        displayDoctorTable = true;
        String queryStringSelect = 'SELECT Id, Name, Sex__c, Languages__c, Location__c, Specialties__c';
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
        }
        queryStringWhere += ' Languages__c includes (\'' + selectedLanguage + '\')';
        NumberOfFilters++;
        
        //dynamically add Specialty preference
        if (numberOfFilters > 0) {
            queryStringWhere += ' AND';          
        }
        
        NumberOfFilters++;
        queryStringWhere += ' Specialties__c includes (\'' + selectedSpecialty + '\')';
        
        //dynamically add Location preference
        if (numberOfFilters > 0) {
            queryStringWhere += ' AND';
            
        }
        NumberOfFilters++; 
        
        if (maxDistance == '') {
        	maxDistance = '30'; //default distance search is 30 miles 
        }
        
        queryStringWhere += ' DISTANCE(Location__c, GEOLOCATION('
            + String.valueOf(currentCustomer.MailingLatitude)+','+String.valueOf(currentCustomer.MailingLongitude) +
            '), \'mi\') < ' + maxDistance;
        NumberOfFilters++;
        
        system.debug(queryStringSelect + queryStringFrom + queryStringWhere);
        
        doctorsToShow = Database.query(queryStringSelect + queryStringFrom + queryStringWhere);
        system.debug(doctorsToShow);
        
    }
    
    //Find all available appointments for a given doctor
    public void searchAvailableAppointments() {
        displayCriteria = false;
        displayDoctorTable = false;
        displayAppointmentTable = true;
       
        DateTime selectedDateTime = DateTime.newInstance(selectedDate.year(), selectedDate.month(), selectedDate.day());
        
        selectedDoctor = [SELECT Id, Name, Work_Hours__c, Workdays__c, Appointment_Length_Minutes__c
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
        system.debug('work hours: ' +workHours);
        
        List<String> workDays = new List<String>();
        workDays.addAll(selectedDoctor.Workdays__c.split(';'));
        system.debug('work days: ' + workDays);
        
        //Build list of possible appointment times
        Boolean appointmentOverlap = false;
        DateTime potentialDateTime = selectedDateTime;
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
                        availableTimes.add(new TimeWrapper(potentialDateTime.format()));
                    }
                }
                potentialDateTime = potentialDateTime.addMinutes(selectedDoctor.Appointment_Length_Minutes__c.intValue());
                //system.debug(potentialDateTime);
                appointmentOverlap = false;
            }
            system.debug('available times: ');
            system.debug(availableTimes);
        }
        
    }
    
    public void selectDependent() {
        appointmentToSave.Coverage_Member__c = selectedDependentID;
        selectedDependent = [SELECT Id, Name FROM Contact WHERE Id = :selectedDependentID LIMIT 1];
    }
    
    public void restartSearch() {
        displayCriteria = true;
        displayAppointmentTable = false;
        displayDoctorTable = false;
        displayAppointmentInfo = false;
        displayConfirmation = false;
        doctorsToShow.clear();
        availableTimes.clear();
        bookedAppointments.clear();
        
    }
    
    public void selectAppointment() {
        displayAppointmentTable = false;
        displayAppointmentInfo = true;
        appointmentToSave.Professional__c = selectedDoctorID;
        appointmentToSave.Start_Time__c = DateTime.parse(selectedStartTime);
        appointmentToSave.Reason_For_Visit__c = selectedSpecialty;
    }
    
    public void closeAppointment() {
        displayAppointmentTable = true;
        displayAppointmentInfo = false;
    }
    
    public void saveAppointment() {
        displayCriteria = false;
        displayAppointmentTable = false;
        displayDoctorTable = false;
        displayAppointmentInfo = false;
        displayConfirmation = true;
        appointmentToSave.Appointment_Type__c = appointmentType;
        insert appointmentToSave;
        
        //Query Template ID
        blankTemplate = [SELECT id FROM EmailTemplate WHERE name = 'Blank With Letterhead'];
        //Send Appointment to primary confirming appointment
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.singleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {currentCustomer.email});
        mail.setSubject('Appointment Confirmed');
        mail.setTemplateId(blankTemplate.id);
        mail.setPlainTextBody(selectedDependent.Name + '\'s appointment with ' + selectedDoctor.name + ' on ' +  selectedStartTime + ' has been confirmed. You will be informed immediately of any changes to the status of the appointment');
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
    
    public class TimeWrapper {
        public String dt {get;set;}
        
        public TimeWrapper(String dt) {
            this.dt = dt;
        }
    } 
}