public class qGiftsLastYear implements Database.Batchable<sObject>
//,Database.Stateful 
{
      
    @InvocableMethod(description='Year End Tax Flow' )
    
    public static void yearEndTaxMethod () {
        database.executeBatch(new qGiftsLastYear(),10); }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer year = Date.Today().year()-1;        
        return Database.getQueryLocator([SELECT LastName, id,Gifts_Last_Year__c, (SELECT Id, CloseDate, Amount FROM Opportunities 
                                                                                  WHERE CALENDAR_YEAR(CloseDate) =:year AND IsWon = True ORDER 
                                                                                  BY CloseDate) FROM Contact WHERE npo02__OppAmountLastYear__c > 1 LIMIT 200000]);          
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        //process each batch of records
        List<Contact> contactsForUpdate = new List<Contact>();
        String loopString;
        String longestString = '<table style="width:100%; border: 1px solid black;"><tr><th style="border: 1px solid black; padding: 15px;"> Date</th>   <th style="border: 1px solid black;">Amount</th></tr>';
        String dateFormatString = 'MMMM d, yyyy';
        String finalString;
        for (Contact con : scope) {
            for (Opportunity opp : con.opportunities) {
                Date d = opp.CloseDate;
                Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                String dateString = dt.format(dateFormatString);
                String cleanAmt = String.valueOf(opp.Amount);
                
                loopString =
                    '<tr> <td style="border: 1px solid black; padding: 15px;">' + dateString +
                    '</th> <td style="border: 1px solid black; padding: 15px;"> $' + cleanAmt + '</th> </tr>';
                longestString = longestString + loopString;
            }
            finalstring = longestString + '</table>';
            con.Gifts_Last_Year__c = String.escapeSingleQuotes(finalstring);
            contactsForUpdate.add(con);
            //reset the value of longestString to the start. otherwise it's going to add everyone's gifts to the list and keep growing. 
			longestString = '<table style="width:100%; border: 1px solid black;"><tr><th style="border: 1px solid black; padding: 15px;"> Date</th>   <th style="border: 1px solid black;">Amount</th></tr>';
             system.debug('Final String' + finalstring);
        }
        update contactsForUpdate;
       
    }

    public void finish(Database.BatchableContext bc){}
}