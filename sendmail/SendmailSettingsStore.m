classdef SendmailSettingsStore < SettingsStore

    properties
        emailFrom
        password
        
        emailTo
        
        smtpAuth 
        smtpServer
        configType
    end

    methods
        function configureForGmail(s, emailFrom, pass)
            % configureForGmail(emailFrom, pass)
            % you must still set .emailTo after using this
            if isempty(strfind(emailFrom, '@'))
                email = strcat(emailFrom, '@gmail.com');
            end

            s.emailFrom = emailFrom;
            s.password = pass;
            s.smtpAuth = true;
            s.smtpServer = 'smtp.gmail.com';
            s.configType = 'gmail';
        end
    end

    methods(Static)
        function name = getMatFileName()
            name = 'sendmailSettings';
        end
    end

end
