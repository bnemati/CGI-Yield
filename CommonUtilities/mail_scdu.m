function mail_scdu(subject, text, addresses)

    command = 'mail';
    
    if (isunix)
        if (system(['which ' command]))
            display 'mail is not installed on this computer';
        end
        if (nargin == 2)
            addresses = 'bijan.nemati@jpl.nasa.gov thomas.a.werne@jpl.nasa.gov xu.wang@jpl.nasa.gov chengxing.zhai@jpl.nasa.gov';
        end
    
        system(['echo "' text '" | mail -s "' subject '" ' addresses]);
        
    else
        display 'Command only works on Unices with the mail program';
    end
    
return