require_relative 'calendar'
require_relative 'spreadsheet'
require_relative 'authorizer'

class Invoicer
  SCOPES = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS, Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY]

  def create
    authorization = Authorizer.authorize(scope: SCOPES)
    calendar = Calendar.new(authorization: authorization)
    events = calendar.fetch_events
    spreadsheet = Spreadsheet.new(events: events, authorization: authorization)
    spreadsheet.create
  end
end

Invoicer.new.create
