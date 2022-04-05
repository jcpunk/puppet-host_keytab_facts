# frozen_string_literal: true

Facter.add(:host_keytab) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  confine kernel: 'Linux'
  retval = {}

  if File.exist?('/etc/krb5.keytab')
    if Facter::Util::Resolution.which('klist')
      Facter::Util::Resolution.exec('klist -ket 2>/dev/null | tail -n +4').each_line do |line|
        # only parse lines with text
        unless line.match?(%r{.+})
          next
        end

        columns = line.split

        kvno = columns[0]
        timestamp = "#{columns[1]} #{columns[2]}"
        principal = columns[3]
        enc = columns[4]

        unless retval.key?(principal)
          retval[principal] = {}
        end
        unless retval[principal].key?(kvno)
          retval[principal][kvno] = {}
        end

        retval[principal][kvno][enc] = timestamp
      end
    end
  end

  setcode do
    retval
  end
end
