//Code by Jessie Rymph
//December 30, 2021

//https://wp.me/p9qPLI-1q8

@isTest
public class yearEndtestDataFactory {
   
    public static Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
   
    //gifts last year
    public static List<Contact> giftsThisYear(Integer numCts, Integer numOppsPerCt){        
        List<Contact> cons = new List<Contact>();
        for(Integer i=0;i<numCts;i++) {
            Contact a = new Contact(LastName='Test'+i,Email='basket@gmail.com',npo02__OppsClosedThisYear__c =3);
            Cons.add(a);
        }
        insert Cons;
        system.debug('insert' + cons);
       
        List<Opportunity> opps = new List<Opportunity>();
       
        for (Integer j=0;j<numCts;j++) {
            Contact connie = Cons[j];
            //get today's date
            Date myDate = system.today();
            //get the year from the date
            Integer thisYear = myDate.year();
            //set a date variable for January 1 of this year. This will be the first gift date.
            Date janDate = Date.newInstance(thisyear, 1, 1);
            // For each contact just inserted, add opportunities
            for (Integer k=0;k<numOppsPerCt;k++) {
                opps.add(new Opportunity(Name=connie.Name + ' Opportunity ' + k,
                                         recordTypeid=devRecordTypeId,
                                         AccountId=connie.AccountId,
                                         StageName='Closed Won',
                                         CloseDate=janDate.addmonths(k),
                                         Amount=k+990,
                                         npsp__Primary_Contact__c=connie.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        system.debug('all Test Opps created');
        return cons;
       
    }
    
    public static List<Contact> sendGiftReceiptCheckthisYear(Integer numCts, Integer numOppsPerCt){
        
        List<Contact> cons = new List<Contact>();
        for(Integer i=0;i<numCts;i++) {
            Contact a = new Contact(LastName='Test'+i,Email='basket@gmail.com',End_of_Year_Gift_Receipt__c=True);
            Cons.add(a);
        }
        insert Cons;
        system.debug('insert' + cons);
       
        List<Opportunity> opps = new List<Opportunity>();
       
        for (Integer j=0;j<numCts;j++) {
            Contact connie = Cons[j];
            //get today's date
            Date myDate = system.today();
            //get the year from the date
            Integer thisYear = myDate.year();
            //set a date variable for January 1 of this year. This will be the first gift date.
            Date janDate = Date.newInstance(thisyear, 1, 1);
            // For each contact just inserted, add opportunities
            for (Integer k=0;k<numOppsPerCt;k++) {
                opps.add(new Opportunity(Name=connie.Name + ' Opportunity ' + k,
                                         recordTypeid=devRecordTypeId,
                                         AccountId=connie.AccountId,
                                         StageName='Closed Won',
                                         CloseDate=janDate.addyears(k),
                                         Amount=k+990,
                                         npsp__Primary_Contact__c=connie.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        system.debug('all Test Opps created');
        return cons;
       
    }
       
    //gifts two years ago
    public static List<Contact> gifts2YearsAgo(Integer numCts, Integer numOppsPerCt){
        //create Test Data
        Campaign camp = new Campaign (Name = 'Annual Fund');
        insert camp;
       
        List<Contact> cons = new List<Contact>();
       
        for(Integer i=0;i<numCts;i++) {
            Contact a = new Contact(LastName='Test'+i,Email='basket@gmail.com',npo02__OppAmountLastYear__c=40, npo02__OppAmountThisYear__c=60);
            Cons.add(a);
        }
        insert Cons;
        system.debug('insert' + cons);
       
        List<Opportunity> opps = new List<Opportunity>();
       
        for (Integer j=0;j<numCts;j++) {
            Contact connie = Cons[j];
            //get the year of last year. start by getting today's date.
            Date myDate = system.today();
            //get the year from the date
            Integer thisYear = myDate.year();
            //subtract one to make it last year
            Integer twoYears = thisYear - 2;
            //set a date variable for January 1 of last year. This will be the first gift date.
            Date janDate = Date.newInstance(twoYears, 1, 1);
            // For each contact just inserted, add opportunities
            for (Integer k=0;k<numOppsPerCt;k++) {
                opps.add(new Opportunity(Name=connie.Name + ' Opportunity ' + k,
                                         recordTypeid= devRecordTypeId,
                                         AccountId=connie.AccountId,
                                         StageName='Closed Won',
                                         CampaignId = camp.Id,
                                         //for each opp created use the JanDate variable, one month later
                                         CloseDate=janDate.addmonths(k),
                                         Amount=k+990,
                                         npsp__Primary_Contact__c=connie.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        system.debug('all Test Opps created');
        return cons;
       
    }
     public static List<Contact> giftsLastYear(Integer numCts, Integer numOppsPerCt){
        //create Test Data
        Campaign camp = new Campaign (Name = 'Annual Fund');
        insert camp;
       
        List<Contact> cons = new List<Contact>();
       
        for(Integer i=0;i<numCts;i++) {
            Contact a = new Contact(LastName='Test'+i,Email='basket@gmail.com',npo02__OppAmountLastYear__c=40, npo02__OppAmountThisYear__c=60);
            Cons.add(a);
        }
        insert Cons;
        system.debug('insert' + cons);
       
        List<Opportunity> opps = new List<Opportunity>();
       
        for (Integer j=0;j<numCts;j++) {
            Contact connie = Cons[j];
            //get the year of last year. start by getting today's date.
            Date myDate = system.today();
            //get the year from the date
            Integer thisYear = myDate.year();
            //subtract one to make it last year
            Integer twoYears = thisYear - 1;
            //set a date variable for January 1 of last year. This will be the first gift date.
            Date janDate = Date.newInstance(twoYears, 1, 1);
            // For each contact just inserted, add opportunities
            for (Integer k=0;k<numOppsPerCt;k++) {
                opps.add(new Opportunity(Name=connie.Name + ' Opportunity ' + k,
                                         recordTypeid= devRecordTypeId,
                                         AccountId=connie.AccountId,
                                         StageName='Closed Won',
                                         CampaignId = camp.Id,
                                         //for each opp created use the JanDate variable, one month later
                                         CloseDate=janDate.addmonths(k),
                                         Amount=k+990,
                                         npsp__Primary_Contact__c=connie.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        system.debug('all Test Opps created');
        return cons;
       
    }
}