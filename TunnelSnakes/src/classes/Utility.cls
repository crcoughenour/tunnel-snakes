/* Developer: Stuart Zeiger
 * Created on: 12-22-18
 * Description: utility class that contains useful static methods
 */

public with sharing class Utility 
{
    public static Integer randomNumber(Integer size)
    {
        return (Math.random()*size).intValue();
    }
    
    public static Integer randomNumber(Integer lowerBound, Integer upperBound)
    {
        return (Math.random()*(upperBound - lowerBound)).intValue() + lowerBound;
    }
}