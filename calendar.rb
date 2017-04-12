require 'google/apis/calendar_v3'
require_relative 'authorizer'

class Calendar
  def initialize(authorization:)
    @authorization = authorization
  end

  def fetch_events
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = Authorizer::APPLICATION_NAME
    service.authorization = @authorization

    calendar_id = 'primary'
    now = Time.now
    first_day_of_month = Date.new(now.year, now.month, 1).to_time.iso8601
    last_day_of_month = Date.new(now.year, now.month, -1).to_time.iso8601
    response = service.list_events(calendar_id,
     single_events: true,
     order_by: 'startTime',
     time_min: first_day_of_month,
     time_max: last_day_of_month)

    puts "Upcoming events:"
    puts "No upcoming events found" if response.items.empty?
    response.items.each do |event|
      start_time = event.start.date_time
      end_time = event.end.date_time
      hours = ((end_time - start_time) * 24).to_i
      puts "- #{event.summary} (#{hours}) - date: #{ start_time } - #{ end_time }"
    end

    return response.items
  end
end
