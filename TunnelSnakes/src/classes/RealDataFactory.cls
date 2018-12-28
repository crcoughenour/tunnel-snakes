public class RealDataFactory {
    
    List<String> states = new List<String>{'VA','GA','NC','SC','FL','TN'};
    List<String> sexes = new List<String>{'Male','Female'};
    List<String> ailments = new List<String>{'Cancer','Heart Failure', 'Diabetes', 'Plaque Psoriasis'};
    List<String> languages = new List<String>{'English','Spanish','Chinese'};
    List<String> appointmentTypes = new List<String>{'Check-up','Lab Test','Treatment','Consultation'};
            
    ID pRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
    ID cmRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Coverage Member').getRecordTypeId();
    
    //random doctors
    public void generateDoctors(integer numDoctors) {
        List<Contact> doctorsToAdd = new List<Contact>();
        
        for(integer i = 0; i < numDoctors; i++) {
            Contact newDoctor = new Contact();
            newDoctor.lastName = 'Doctor'+i;
            newDoctor.mailingState = (String)Utility.getRandomObjectFromList(states);
            newDoctor.sex__c = (String)Utility.getRandomObjectFromList(sexes);  
            newDoctor.specialties__c = (String)Utility.getRandomObjectFromList(ailments); 
            newDoctor.languages__c = (String)Utility.getRandomObjectFromList(languages);
            newDoctor.recordTypeId = pRecordTypeID; 
            newDoctor.email = 'crcoughenour@gmail.com';
            doctorsToAdd.add(newDoctor); 
        }
        
        insert doctorsToAdd;
    }
    
    //random customers
    public void generateCustomers(integer numCustomers) {
        List<Contact> customersToAdd = new List<Contact>();

        for(integer i = 0; i < numCustomers; i++) {
            Contact newCustomer = new Contact();
            newCustomer.lastName = 'Customer'+i;
            newCustomer.mailingState = (String)Utility.getRandomObjectFromList(states);
            newCustomer.sex__c = (String)Utility.getRandomObjectFromList(sexes);  
            newCustomer.affliction__c = (String)Utility.getRandomObjectFromList(ailments); 
            newCustomer.languages__c = (String)Utility.getRandomObjectFromList(languages);
            newCustomer.recordTypeId = cmRecordTypeID;
            newCustomer.email = 'crcoughenour@gmail.com';
            customersToAdd.add(newCustomer);  
        }
        
        insert customersToAdd;
    }
    
    //random appointments
    public void generateAppointments(integer numAppointments) {
        List<Contact> allDoctors = [SELECT id, recordTypeID FROM Contact WHERE recordTypeID = :pRecordTypeID];
        List<Contact> allCustomers = [SELECT id, recordTypeID FROM Contact WHERE recordTypeID = :cmRecordTypeID];
        
        DateTime startTime = DateTime.newInstance(2018, 12, 31);
        
        List<Appointment__c> appointmentsToAdd = new List<Appointment__c>();
        
        for(integer i = 0; i < numAppointments; i++) {
            Appointment__c newAppointment = new Appointment__c();
            newAppointment.Appointment_Type__c = (String)Utility.getRandomObjectFromList(appointmentTypes);
            newAppointment.Reason_For_Visit__c = (String)Utility.getRandomObjectFromList(ailments);
            newAppointment.Start_Time__c = startTime;
            
            Contact doctor = (Contact)Utility.getRandomObjectFromList(allDoctors);
            newAppointment.professional__c = doctor.id;
            
            Contact cm = (Contact)Utility.getRandomObjectFromList(allCustomers);
            newAppointment.coverage_member__c = cm.id;
            
            appointmentsToAdd.add(newAppointment);
        }
        
        insert appointmentsToAdd;
        
    }
    
}