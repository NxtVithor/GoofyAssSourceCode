function loadAnimations()
{
        addByPrefix('idle', 'nxxty idle', 12);
        addByPrefix('singUP', 'nxxty up', 12);
        addByPrefix('singRIGHT', 'nxxty right', 12);
        addByPrefix('singDOWN', 'nxxty down', 12);
        addByPrefix('singLEFT', 'nxxty left', 12);
        
        addOffset('idle', 0, 4);
        addOffset('singUP', 0, 4);
        addOffset('singDOWN', 0, 4);
        addOffset('singLEFT', 0, 4);
        addOffset('singRIGHT', 0, 4);

        flipLeftRight();
        
    
        playAnim('idle');
        setBarColor([175,102,206]);
        setScale(0.6, 0.6);
        setOffsets(-120, 690);
}
