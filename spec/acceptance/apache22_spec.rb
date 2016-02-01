require 'spec_helper_acceptance'

describe 'apache class' do

  context 'hari concats' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache': }

    	class {'apache::fcgi':
    		fcgihost => '192.168.56.28',
    	}

      apache::vhost {'default':
        defaultvh=>true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "sleep 10 to make sure apache is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    describe port(80) do
      it { should be_listening }
    end

    describe package($packagename) do
      it { is_expected.to be_installed }
    end

    describe service($servicename) do
      it { should be_enabled }
      it { is_expected.to be_running }
    end

    #default vhost
    describe file("${baseconf}/conf.d/00_default.conf") do
      it { should be_file }
      its(:content) { should match 'Order Deny,Allow' }
      its(:content) { should match 'DocumentRoot /var/www/void' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-80.conf

  end

end
