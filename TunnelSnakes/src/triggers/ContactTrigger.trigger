trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
    	ContactTriggerHelper.ContactAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }
}