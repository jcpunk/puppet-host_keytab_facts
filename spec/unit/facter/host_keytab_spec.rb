# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/host_keytab'

describe :host_keytab, type: :fact do
  subject(:fact) { Facter.fact(:host_keytab) }

  before :each do
    # perform any action that should be run before every test
    Facter.clear
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
  end

  let(:complex_output) do
    <<~EOS
   2 10/07/2017 13:03:17 host/testify.example.com@EXAMPLE.COM (DEPRECATED:des-cbc-crc)
   3 10/07/2019 14:39:44 host/testify.example.com@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 host/testify.example.com@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 host/testify.example.com@EXAMPLE.COM (DEPRECATED:des3-hmac-sha1)
   3 10/07/2019 14:39:44 host/testify.example.com@EXAMPLE.COM (DEPRECATED:des-cbc-crc)
   3 10/07/2019 14:39:44 nfs/testify.example.com@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 nfs/testify.example.com@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 nfs/testify.example.com@EXAMPLE.COM (DEPRECATED:des3-hmac-sha1)
   3 10/07/2019 14:39:44 nfs/testify.example.com@EXAMPLE.COM (DEPRECATED:des-cbc-crc)
   3 10/07/2019 14:39:44 HTTP/testify.example.com@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 HTTP/testify.example.com@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   3 10/07/2019 14:39:44 HTTP/testify.example.com@EXAMPLE.COM (DEPRECATED:des3-hmac-sha1)
   3 10/07/2019 14:39:44 HTTP/testify.example.com@EXAMPLE.COM (DEPRECATED:des-cbc-crc)
    EOS
  end

  context 'no keytab' do
    before :each do
      expect(File).to receive(:exist?).with('/etc/krb5.keytab').and_return(false)
      expect(Facter::Util::Resolution).not_to receive(:which).with('klist')
    end

    it do
      expect(Facter.fact('host_keytab').value).to eq({})
    end
  end

  context 'no klist' do
    before :each do
      expect(File).to receive(:exist?).with('/etc/krb5.keytab').and_return(true)
      expect(Facter::Util::Resolution).to receive(:which).with('klist').and_return('')
    end

    it do
      expect(Facter.fact('host_keytab').value).to eq({})
    end
  end

  context 'no slots' do
    before :each do
      expect(File).to receive(:exist?).with('/etc/krb5.keytab').and_return(true)
      expect(Facter::Util::Resolution).to receive(:which).with('klist').and_return('klist')
      expect(Facter::Util::Resolution).to receive(:exec).with('klist -ket 2>/dev/null | tail -n +4').and_return('')
    end

    it do
      expect(Facter.fact('host_keytab').value).to eq({})
    end
  end

  context 'lots of slots' do
    before :each do
      expect(File).to receive(:exist?).with('/etc/krb5.keytab').and_return(true)
      expect(Facter::Util::Resolution).to receive(:which).with('klist').and_return('klist')
      expect(Facter::Util::Resolution).to receive(:exec).with('klist -ket 2>/dev/null | tail -n +4').and_return(complex_output)
    end

    it do
      expect(Facter.fact('host_keytab').value).to eq(
      {
        'HTTP/testify.example.com@EXAMPLE.COM' => {
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        },
        'host/testify.example.com@EXAMPLE.COM' => {
          '2' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2017 13:03:17'
          },
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        },
        'nfs/testify.example.com@EXAMPLE.COM' => {
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        }
      },
    )
    end
  end
end
