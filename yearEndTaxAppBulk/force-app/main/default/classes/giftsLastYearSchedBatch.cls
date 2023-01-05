global class giftsLastYearSchedBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
       qGiftsLastyear q = new qgiftsLastYear();
       database.executebatch(q);
   }
}