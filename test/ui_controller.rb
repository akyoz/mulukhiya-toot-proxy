module Mulukhiya
  class UIControllerTest < TestCase
    include ::Rack::Test::Methods

    def setup
      @config = Config.instance
    end

    def app
      return UIController
    end

    def test_media
      get '/media'
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      get '/media/noexist'
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      get '/media/icon.png'
      assert(last_response.ok?)
      assert_equal(last_response.headers['Content-Type'], 'image/png')

      get '/media/poyke.mp4'
      assert(last_response.ok?)
      assert_equal(last_response.headers['Content-Type'], 'video/mp4')

      get '/media/hugttocatch.mp3'
      assert(last_response.ok?)
      assert_equal(last_response.headers['Content-Type'], 'audio/mpeg')
    end
  end
end
