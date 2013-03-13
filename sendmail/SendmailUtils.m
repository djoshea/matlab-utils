classdef SendmailUtils < handle

    methods(Static)
        function s = configureSendmail()
            s = SendmailSettingsStore();

            setpref('Internet','E_mail', s.emailFrom);
            setpref('Internet','SMTP_Server', s.smtpServer);
            setpref('Internet','SMTP_Username', s.emailFrom);
            setpref('Internet','SMTP_Password', s.password);

            props = java.lang.System.getProperties;
            
            if s.smtpAuth
                auth = 'true';
            else
                auth = 'false';
            end
            props.setProperty('mail.smtp.auth', auth);
            props.setProperty('mail.smtp.socketFactory.class', ...
                                'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port','465');
        end
        
        function sendTo(to, subject, message, attach)
            SendmailUtils.configureSendmail();
            if ~iscell(attach)
                attach = {attach};
            end
            debug('Sending email to %s with %d attachments with subject "%s"\n', ...
                to, length(attach), subject);
            sendmail(to, subject, message, attach);
        end
        
        function send(subject, message, varargin)
            % send(subject, message, varargin)
            % to email address determined by SendmailUtils
            s = SendmailSettingsStore();
            SendmailUtils.sendTo(s.emailTo, subject, message, varargin{:});
        end
        
        function sendFigure(varargin)
            p = inputParser;
            p.addOptional('hFig', gcf, @ishandle);
            p.addOptional('name', '', @ischar);
            p.addOptional('caption', '', @ischar);
            p.parse(varargin{:});

            hFig = p.Results.hFig;
            name = p.Results.name;
            caption = p.Results.caption;

            % get name and caption for figure
            if isempty(name)
                % no name provided, default to figure title
                ca = get(hFig, 'currentAxes');
                hTitle = get(ca, 'Title');
                if ~isempty(hTitle)
                    name = get(hTitle, 'String');
                end

                if isempty(name)
                    name = input('Figure name: ', 's');
                end
            end

            if isempty(caption)
                caption = input('Figure caption (optional): ', 's');
            end
            
            % save the figure file
            figname = fullfile(tempdir(), sprintf('%s at %s', name, datestr(now)));
            fileList = saveFigure(hFig, figname, {'png', 'fig'});
            
            SendmailUtils.send(name, caption, fileList);
            
        end
    end

end
