require 'google/apis/sheets_v4'
require_relative 'authorizer'

class Spreadsheet
  def initialize(events: [], rate_per_h: 45, authorization:)
    @events = events
    @rate_per_h = rate_per_h
    @authorization = authorization
  end

  def create
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = Authorizer::APPLICATION_NAME
    service.authorization = @authorization

    request_body = Google::Apis::SheetsV4::Spreadsheet.new(sheet_hash)
    p request_body
    response = service.create_spreadsheet(request_body)
    p response
  end

  def sheet_hash
    {
      sheets: [
        {
          data: events_data
        }
      ],
      properties: {
        title: 'test'
      }
    }
  end

  def events_data
    data = []
    last_row_index = 0
    @events.each.with_index do |event, i|
      data << event_hash(event, i)
      last_row_index += 1
    end
    data << total_hours(last_row_index: last_row_index)
    last_row_index += 1
    data << rate_per_h(last_row_index: last_row_index)
    last_row_index += 1
    data << total(last_row_index: last_row_index)
    data
  end

  def event_hash(event, i)
    {
      start_row: i,
      row_data: [
        {
          values: [
            {
              user_entered_value: {
                string_value: event_date(event).to_s
              }
              },
              {
                user_entered_value: {
                  number_value: event_time(event).to_s
                }
              }
            ]
          }
        ]
      }
    end

    def event_date(event)
      event.start.date_time
    end

    def event_time(event)
      start_time = event.start.date_time
      end_time = event.end.date_time
      ((end_time - start_time) * 24).to_i
    end

    def total_hours(last_row_index:)
      new_row(last_row_index + 1, string_value: 'Total hours', formula_value: "=SUM(B1:B#{ last_row_index })")
    end

    def rate_per_h(last_row_index:)
      new_row(last_row_index + 1, string_value: 'Rate per hour', number_value: @rate_per_h)
    end

    def total(last_row_index:)
      new_row(last_row_index + 1, string_value: 'Total', formula_value: "=(B#{last_row_index }*B#{ last_row_index + 1 })")
    end

    def new_row(row_index, *args)
      {
        start_row: row_index,
        row_data: [
         {
          values: row_data_values(*args)
        }
      ]
    }
  end

  def row_data_values(args)
    result = []
    args.each do |value_type, value|
      result << {
        user_entered_value: {
          value_type => value
        }
      }
    end
    result
  end
end
