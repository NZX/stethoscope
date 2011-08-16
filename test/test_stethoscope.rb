require 'test_helper'

class TestStethoscope
  extend  Nanotest
  extend  Nanotest::Contexts
  extend StethoscopeTestHelpers
  extend Rack::Test::Methods

  context do
    setup    { setup_app }
    teardown do
      Stethoscope.url = "/heartbeat"
      Stethoscope.clear_checks
    end


    # When accessing normal url's should not intercept anything
    test do
      response = get "/"
      assert { response.status == 200     }
      assert { response.body.to_s == "default" }
    end

    # When accessing the Stethoscope.url should intercept the call
    test do
      response = get "/heartbeat"
      assert { response.status == 200 }
      assert { response.body.to_s =~ /Ba-Boomp/ }
    end

    # With a different url
    test do
      Stethoscope.url = "/something_else"
      response = get "/heartbeat"
      assert {response.body.to_s =~ /default/  }
      response = get "/something_else"
      assert {response.body.to_s =~ /Ba-Boomp/ }
    end

    test do
      Stethoscope.check(:foo){ |response| response[:status] = 200; response[:test1] = :test1 }
      Stethoscope.check(:bar){ |response| response[:status] = 200; response[:test2] = :test2 }

      response = get "/heartbeat.json"
      assert { response.status == 200    }
      assert { response.body !~ /default/ }
      result = JSON.parse(response.body)
      assert { result['status'] == 200 }
      assert { result['checks'] == {'foo' => {'status' => 200, 'test1' => 'test1'}, 'bar' => {'status' => 200, 'test2' => 'test2'} } }
    end

    # Check checks
    context do
      setup    { $captures = []  }
      teardown { $captures.clear }
      # Check that checks run
      test do
        Stethoscope.check(:foo){ |response| response[:status] = 200;$captures << :foo; }
        Stethoscope.check(:bar){ |response| response[:status] = 200;$captures << :bar; }

        response = get "/heartbeat"
        assert { response.status == 200    }
        assert { $captures == [:foo, :bar] }
      end

      # Check, and fail the run
      test do
        Stethoscope.check(:foo){ |response| $captures << :foo; }
        Stethoscope.check(:bar){ |response| response[:status] = 500;$captures << :bar; }

        response = get "/heartbeat"
        assert { response.status == 500 }
      end

      # should render the reason
      test do
        Stethoscope.check(:something) do |resp|
          resp[:status] = 423
          resp[:reason] = "Something went wrong capt'n"
        end

        response = get "/heartbeat"
        assert { response.status == 500 }
        assert { response.body.to_s =~ /Something went wrong capt'n/m }
      end

      # should handle tests being nilled
      test do
        Stethoscope.check('foo'){}
        assert { Proc === Stethoscope.checks['foo'] }
        Stethoscope.remove_check('foo')
        assert { !Stethoscope.checks.key?('foo') }
      end

      # should give a 500 status if there is an exception
      test do
        Stethoscope.check('foo'){ |resp| raise "Oh Noes" }

        response = get "/heartbeat"
        assert { response.status == 500 }
      end
    end
  end
end

