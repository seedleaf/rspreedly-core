module FakeHttp
  def load_fixture(file)
    response_file = File.join(File.dirname(__FILE__), '..', 'fixtures', file)
    File.read(response_file)
  end

  def stub_http_with_fixture(fixture, status = 200)
    stub_http_response(:body => load_fixture(fixture), :code => status)
  end

  def stub_http_with_code(status = 200)
    stub_http_response(:code => status)
  end

  def stub_http_response(opts={})
    http_response = mock('response')
    http_response.stubs(:[])

    http_response.stubs(:body).returns(opts[:body] || "")
    http_response.stubs(:message).returns("")
    http_response.stubs(:kind_of?).returns(true)
    http_response.stubs(:code).returns(opts[:code] || 200)
    http_response.stubs(:to_hash).returns({})

    mock_http = stub_everything('net_http', :use_ssl= => true, :use_ssl? => true, :verify_mode= => 0)
    mock_http.stubs(:request).returns(http_response)

    Net::HTTP.stubs(:new).returns(mock_http)
  end

end
