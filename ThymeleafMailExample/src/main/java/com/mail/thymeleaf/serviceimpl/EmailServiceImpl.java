package com.mail.thymeleaf.serviceimpl;



import java.util.Properties;

import org.slf4j.LoggerFactory;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.mail.thymeleaf.model.EmailRequest;
import com.mail.thymeleaf.model.EmailResponse;
import com.mail.thymeleaf.model.Status;
import com.mail.thymeleaf.service.EmailService;

@Service
public class EmailServiceImpl implements EmailService {

	/** The logger. */
	private org.slf4j.Logger logger = LoggerFactory.getLogger(this.getClass());
	
	private final String MAIL_TRANSPORT_PROTOCOL = "mail.transport.protocol";

	private final String MAIL_SMTP_PORT = "gmail.ses.smtp.port";

	private final String MAIL_SMTP_STARTTLS_ENABLE = "mail.smtp.starttls.enable";

	private final String MAIL_SMTP_AUTH = "mail.smtp.auth";

	private final String MAIL_SMTP_SSL_TRUST = "gmail.smtp.ssl.trust";
	
	/** Email content type */
	private final String MAIL_CONTENT_TYPE = "text/html";

	/** From email address */
	@Value("${gmail.ses.smtp.from}")
	private String sentFrom;

	/**
	/** From email address name 
	@Value("${gmail.ses.smtp.from.name}")
	private String fromName; **/


	/** From email address */
	@Value("${gmail.ses.smtp.username}")
	private String smtpUserName;

	/** From email password */
	@Value("${gmail.ses.smtp.password}")
	private String smtpPassword;

	/** Gmail smtp host server */
	@Value("${gmail.ses.smtp.host}")
	private String host;

	/** Gmail smtp host server port */
	@Value("${gmail.ses.smtp.port}")
	private String port;

	/** Gmail server protocol */
	@Value("${mail.transport.protocol}")
	private String mailTransportProtocol;

	/**
	 * Enable Upgrade from an insecure connection to a secure one using TLS or SSL
	 */
	@Value("${mail.smtp.starttls.enable}")
	private String mailSmtpStarttlsEnable;

	/** Enable smtp AUTH service */
	@Value("${mail.smtp.auth}")
	private String mailSmtpAuth;

	/** Secure connection server */
	@Value("${gmail.smtp.ssl.trust}")
	private String mailSmtpSslTrust;
	
	@Override
	public EmailResponse sendEmail(EmailRequest emailRequest) {
		
		EmailResponse response=null;
		Status status=new Status();
		
		// Create a Properties object to contain connection configuration information.
				Properties props = System.getProperties();
				props.put(MAIL_TRANSPORT_PROTOCOL, mailTransportProtocol);
				props.put(MAIL_SMTP_PORT, port);
				props.put(MAIL_SMTP_STARTTLS_ENABLE, mailSmtpStarttlsEnable);
				props.put(MAIL_SMTP_AUTH, mailSmtpAuth);
				props.put(MAIL_SMTP_SSL_TRUST, mailSmtpSslTrust);

				// Create a Session object to represent a mail session with the specified
				// properties.
				Session session = Session.getDefaultInstance(props);

				Transport transport = null;
				
				try {

					response = new EmailResponse();

					MimeMessage msg = new MimeMessage(session);
					//msg.setFrom(new InternetAddress(sentFrom, fromName));
					msg.setRecipients(Message.RecipientType.TO, populateAddresses(emailRequest.getTo()));
					msg.setSubject(emailRequest.getSubject());
					msg.setContent(emailRequest.getBodyContent(), MAIL_CONTENT_TYPE);

					// Create a transport.
					transport = session.getTransport();

					// Connect to Amazon SES using the SMTP username and password you specified
					// above.
					transport.connect(host, smtpUserName, smtpPassword);

					// Send the email.
					transport.sendMessage(msg, msg.getAllRecipients());

					status.setStatusCode("SUCCESS");
					status.setStatusDescription("SUCCESS");
					response.setStatus(status);

				} catch (MessagingException ex) {
					response = new EmailResponse();
					Status sts = new Status();
					sts.setStatusCode("ERROR");
					status.setStatusDescription("ERROR");
					response.setStatus(sts);
					logger.error("The email was not sent." + ex.getMessage());
				} catch (Exception e) {
					response = new EmailResponse();
					Status sts = new Status();
					sts.setStatusCode("ERROR");
					status.setStatusDescription("ERROR");
					response.setStatus(sts);
					logger.error("The email was not sent." + e.getMessage());
				} finally {
					// Close and terminate the connection.
					try {
						transport.close();
					} catch (MessagingException e) {
						response = new EmailResponse();
						Status sts = new Status();
						sts.setStatusCode("ERROR");
						status.setStatusDescription("ERROR");
						response.setStatus(sts);
						logger.error("The email was not sent." + e.getMessage());
					}
				}

				return response;
			}

			private InternetAddress[] populateAddresses(String toEmails) {

				String[] recipientList = toEmails.split(",");
				InternetAddress[] recipientAddress = new InternetAddress[recipientList.length];
				int counter = 0;
				for (String recipient : recipientList) {
					try {
						recipientAddress[counter] = new InternetAddress(recipient.trim());
					} catch (AddressException e) {
						logger.error("Recipient emails are not populated." + e.getMessage());
					}
					counter++;
				}

				return recipientAddress;
			
	}
	

}
