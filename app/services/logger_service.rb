class LoggerService
  def self.log(message)
    Rails.logger.error(message)
  end
end
