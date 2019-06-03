require 'spec_helper'

describe 'postfix::hash' do
  let (:title) { '/tmp/foo' }

  let :pre_condition do
    "class { '::postfix': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'when passing wrong type for ensure' do
        let (:params) { {
          :ensure => ['present'],
        } }
        it 'should fail' do
          expect {
            is_expected.to contain_concat('/tmp/foo')
          }.to raise_error
        end
      end

      context 'when passing wrong value for ensure' do
        let (:params) { {
          :ensure => 'running',
        } }
        it 'should fail' do
          expect {
            is_expected.to contain_concat('/tmp/foo')
          }.to raise_error(Puppet::Error, /got 'running'/)
        end
      end

      context 'when passing wrong value for title' do
        let (:title) { 'foo' }
        it 'should fail' do
          expect {
            is_expected.to contain_concat('/tmp/foo')
          }.to raise_error(Puppet::Error, /, got /)
        end
      end

      context 'when passing both source and content' do
        let (:params) { {
          :source  => '/tmp/bar',
          :content => 'bar',
        } }

        it 'should fail' do
          expect {
            is_expected.to contain_concat('/tmp/foo')
          }.to raise_error(Puppet::Error, /You must provide either 'source' or 'content'/)
        end
      end

      context 'when passing source' do
        let (:params) { {
          :source  => '/tmp/bar',
        } }

        it { is_expected.to contain_concat('/tmp/foo').with_ensure('present') }
        it { is_expected.to contain_concat__fragment('/tmp/foo source').with_source('/tmp/bar') }
        it { is_expected.to contain_file('postfix map /tmp/foo.db').with_ensure('present') }
        it { is_expected.to contain_exec('generate /tmp/foo.db') }

      end

      context 'when passing content' do
        let (:params) { {
          :content => 'bar',
        } }

        it { is_expected.to contain_concat('/tmp/foo').with_ensure('present') }
        it { is_expected.to contain_concat__fragment('/tmp/foo content').with_content('bar') }
        it { is_expected.to contain_file('postfix map /tmp/foo.db').with_ensure('present') }
        it { is_expected.to contain_exec('generate /tmp/foo.db') }
      end

      context 'when not passing source or content' do
        it { is_expected.to contain_concat('/tmp/foo').with_ensure('present') }
        it { is_expected.not_to contain_concat__fragment('/tmp/foo source') }
        it { is_expected.not_to contain_concat__fragment('/tmp/foo content') }
        it { is_expected.to contain_file('postfix map /tmp/foo.db').with_ensure('present') }
        it { is_expected.to contain_exec('generate /tmp/foo.db') }
      end

      context 'when ensuring absence' do
        let (:params) { {
          :ensure => 'absent',
        } }

        it { is_expected.to contain_concat('/tmp/foo').with_ensure('absent') }
        it { is_expected.not_to contain_concat__fragment('/tmp/foo source') }
        it { is_expected.not_to contain_concat__fragment('/tmp/foo content') }
        it { is_expected.to contain_file('postfix map /tmp/foo.db').with_ensure('absent') }
        it { is_expected.to contain_exec('generate /tmp/foo.db') }
      end
    end
  end
end
