# Assuming message is a string with the outcome of the resend confirmation process
json.set! :status, response[:status]
json.set! :message, response[:message] if response[:message].present?
json.set! :error, response[:error] if response[:error].present?
