#  BonitaProbe

A collection of reports and utilities for probing and securing Bonita.

The Bonita REST API vulnerability represents a critical security flaw that allows any authenticated user to download the entire business database and system data, including sensitive BDM objects, user accounts, groups, and roles. The flaw encompasses multiple vulnerability types—broken access control, insecure direct object reference, excessive data exposure, and lack of rate limiting—making it exceptionally easy to exploit. In multi-client environments, this results in unrestricted cross-client data exposure, enabling users from one organization to access the data of others. The exposure of usernames, which can be used to target accounts for hijacking, significantly increases the risk of further breaches. The simplicity of the API endpoints, combined with the potential for endpoint compromise, creates a scenario where sensitive data is effectively exposed to the global internet, posing severe risks to organizations and data subjects.

**From a GDPR perspective, the vulnerability violates core principles of data protection, including security, data protection by design, and purpose limitation**. The exposure of personal data, particularly usernames, in multi-client deployments amplifies the severity of these violations, as it undermines the confidentiality and integrity of data belonging to multiple organizations. Data controllers using Bonita face significant legal, financial, and reputational risks due to non-compliance with GDPR requirements.

See full documentation:

- [Severe Security Flaws in Bonita](./bonita-flaws.md)

• • • 

---

## Resources and Tools

This bundle compiles **publicly available information** and offers free tools derived from such data to enhance cybersecurity analysis, focusing on security vulnerabilities and GDPR compliance. It does not reveal confidential information but systematically organizes existing resources and tools to clearly illustrate concepts and provide effective demonstrations.

This resource was thoroughly tested on *Bonita v7.11*, deployed with *Apache Tomcat v8.5.53*.

### Information Resources

The list below is not exhaustive but represents an initial overview.

- [Archived Bonita documentation](https://documentation.bonitasoft.com/bonita/0/archives)
- [Bonita documentation](https://documentation.bonitasoft.com/bonita/)
- Tomcat CVE's:
  - [CVE-2020-9484](https://nvd.nist.gov/vuln/detail/cve-2020-9484)
  - [CVE-2021-25122](https://nvd.nist.gov/vuln/detail/cve-2021-25122)
  - [CVE-2021-25329](https://nvd.nist.gov/vuln/detail/cve-2021-25329)
  - [CVE-2021-33037](https://nvd.nist.gov/vuln/detail/cve-2021-33037)
  - [CVE-2021-41079](https://nvd.nist.gov/vuln/detail/cve-2021-41079)
  - [CVE-2021-42340](https://nvd.nist.gov/vuln/detail/cve-2021-42340)
  - [CVE-2023-24998](https://nvd.nist.gov/vuln/detail/cve-2023-24998)
  - [CVE-2023-42795](https://nvd.nist.gov/vuln/detail/cve-2023-42795)
- Bonita CVE's:
  - [CVE-2022-25237](https://github.com/RhinoSecurityLabs/CVEs/tree/master/CVE-2022-25237)  - Bonita Authorization Bypass
    - [Python scripts related](https://github.com/RhinoSecurityLabs/CVEs/tree/master/CVE-2022-25237) to CVE-2022-25237
  - [CVE-2024-28087](https://nvd.nist.gov/vuln/detail/CVE-2024-28087) - IDOR vulnerability
  - [CVE-2024-27609](https://nvd.nist.gov/vuln/detail/CVE-2024-27609) - Allows stored cross-site scripting (XSS)
  - [CVE-2024-26542](https://nvd.nist.gov/vuln/detail/CVE-2024-26542) - Data theft or session hijacking.
- Misc
  - [Bonita Community](https://community.bonitasoft.com)
  - [Bonita](https://stackoverflow.com/tags/bonita) on StackOverflow

### Tools

- Bonita [downloads](https://sourceforge.net/projects/bonita/) on SourceForge
- Bonita [downloads](https://www.bonitasoft.com/downloads) page

• • • 
