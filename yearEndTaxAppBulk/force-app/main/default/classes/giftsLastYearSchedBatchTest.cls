//Code by Jessie Rymph
//December 21, 2022
//Tests the Year End Gift Batch process using the YearEndtestDataFactory class
//https://wp.me/p9qPLI-1q8

@isTest
public class giftsLastYearSchedBatchTest {
    
    @isTest static void positiveTest() {
        // Test data setup 
        // test for Gifts Last Year
        // Create contacts with opps through test utility
        Integer testNumC= 2;
        Integer testNumO = 2;
        contact[] cons = YearEndTestDataFactory.giftsLastYear(testNumC,testNumO);   
        Test.startTest();
        qGiftsLastYear yEGB = new qGiftsLastYear(); 
        Id batchId = Database.executeBatch(yEGB);
        
        Test.stopTest();     
        List<Contact> contacts = new List<Contact>();
        
        for(Contact person : [SELECT Id, Gifts_Last_Year__c FROM Contact]) {
            if(person.Gifts_Last_Year__c.contains('Date')) {
                contacts.add(person);
            }
        }
        System.assertEquals(testNumC,contacts.size(),testNumC +' ');
    }
    
    @isTest static void negativeTest() {
        // Test data setup
        // Test that this years gifts do not go into Gifts Last Year
        // Create contacts with opps through test utility
        Integer testNumC=10;
        Integer testNumO = 12;
        contact[] cons = YearEndTestDataFactory.GiftsThisYear(testNumC,testNumO);
        
        
        Test.startTest();
        qGiftsLastYear yEGB = new qGiftsLastYear();
        Id batchId = Database.executeBatch(yEGB);
        Test.stopTest();       
        
        List<Contact> contacts = new List<Contact>();
        
        for(Contact person : [SELECT Id, Gifts_Last_Year__c FROM Contact]) {
            
            IF(person.Gifts_Last_Year__c != null) { 
                contacts.add(person);
            }
            
        }
        System.assertEquals(0,contacts.size(),'Expected none, got' + contacts.size());
        
    }
    
    @isTest static void schedTest() {
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        String CRON_EXP = '0 0 0 3 9 ? 2027';
        // Schedule the test job
        String jobId = System.schedule('giftsLastYearSchedBatchTest', CRON_EXP, new giftsLastYearSchedBatch());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
        // Verify the next time the job will run 
        System.assertEquals('2027-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
    }
    
    
}