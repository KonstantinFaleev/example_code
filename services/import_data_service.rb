require 'open-uri'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
require 'openssl'

class ImportDataService
  VERIFY = OpenSSL::SSL::VERIFY_NONE

  def initialize(params)
    @id = params[:id]
    @ref = params[:ref]
    @code = params[:code]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @login = ENV['LOGIN_WEB_SERVICE']
    @password = ENV['PASSWORD_WEB_SERVICE']
    @path = ENV['PATH_WEB_SERVICE']
  end

  def import_post
    if @id.present?
      uri = URI("https://#{@path}/ar_cb/hs/exch/initialsync/data")
    else
      uri = URI("https://#{@path}/ar_cb/hs/exch/cashflow/plan")
    end
    header = {'Content-Type': 'text/json'}
    req = Net::HTTP::Post.new(uri.request_uri, header)
    auth(req)
    parse_body(req)
    parse_date(uri, req)
  end

  private
  def parse_date(uri, req)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: VERIFY) { |http|
      http.request(req)
    }
    JSON.parse(res.body)
  end

  def parse_body(req)
    if @id.present?
      if @ref.present? && @code.present?
        req.body = {id: @id, filter: {ref: @ref, code: @code}}.to_json
      elsif @ref.present?
        req.body = {id: @id, filter: {ref: @ref}}.to_json
      elsif @code.present?
        req.body = {id: @id, filter: {code: @code}}.to_json
      else
        req.body = {id: @id}.to_json
      end
    else
      if @date_from.present? && @date_to.present?
        req.body = {id: "q", dataFrom: parse_time(@date_from), dateTo: parse_time(@date_to)}.to_json
      else
        req.body = {id: "q"}.to_json
      end
    end
  end

  def parse_time(time)
    time.to_date.strftime('%FT%R:00Z')
  end

  def auth(req)
    req.basic_auth @login, @password
  end
end
