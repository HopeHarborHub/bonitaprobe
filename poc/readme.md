# Reproducing the Vulnerability

This section provides proof-of-concept (PoC) Bash scripts to demonstrate the ease with which an authenticated user can exploit the Bonita vulnerabilities to extract entire datasets from the Business Data Model (BDM) and system-related endpoints.

> Please note that numerous online automation tools, such as `airbyte.com`, `rapidapi.com`, `postman.com`, `parabola.io` etc,  are available, offering free or reasonably priced plans with user-friendly interfaces. These tools eliminate the need to write custom scripts. Simply set up an automation project, configure the necessary settings, and the tool will handle the rest.

These scripts are for educational and testing purposes only. 

---

## Configuration

To use the scripts, minimal configuration is required. You can edit the configuration in the `./poc/_config.sh` file or set variables using `export` commands in the terminal. Variables set via the terminal override values in the configuration file, allowing the scripts to be used without modifying the file itself.

### Configuration file

You need to edit following section in  in the `./poc/_config.sh` file.

```bash
# BEGIN Configuration
export BN_SERVER_URL="https://mydomain.com"
export BN_SESS_COOKIE="JSESSIONID=12345678901234567890123456789012"
export BN_RQ_LIMIT=5
export BN_RQ_DElAY_TIME=0.2
# END Configuration
```

**Explanation**

- `BN_SERVER_URL` - Bonita server URL. 
  - Example `https://mydomain.com/bonita` - *Subfolder* deployment.
  - Example `https://mydomain.com/` - *ROOT* deployment.
- `BN_SESS_COOKIE` - Tomcat Session Cookie.
  - Example `JSESSIONID=370760A5A824D070B7898BC734A2F276`
  - The Session ID can be easily obtained from the browser's inspector tool (under cookies) after a successful login.
- `BN_RQ_LIMIT` - Maximum number of pages to retrieve. Default `5`.
- `BN_RQ_DElAY_TIME` -Delay time between requests to prevent excessively frequent requests.

### EXPORT Commands

*Variables set via the terminal override values in the configuration file*. Set values based on the specific requirements and testing targets of your environment.

**Server URL**

```bash
export BONITA_URL=https://mydomain.com/bonita
```

**Session Cookie**

```bash
export BONITA_SESSION_ID=370760A5A824D070B7898BC734A2F276
```

**Requests Limit**

```bash
export BONITA_REQUESTS_LIMIT=3
```

**Delay Time**

```bash
export BONITA_REQUESTS_DELAY=0.5
```

---

## Usage

Download and extract the package, for example, to the `~/bonita-tests` directory. 

### Running a Single Test

This section provides an example of how to run a single test.

```bash
cd ~/bonita-tests/poc # Open scripts directory
export BONITA_URL=https://mydomain.com/bonita # Set URL of Bonita
export BONITA_SESSION_ID=370760A5A824D070B7898BC734A2F276 # Set Session ID
bash ./cve-2022-25237-status.sh # Execute CVE-2022-25237
```

### Running a Bundle of Tests

This section provides an example of how to execute a bundle of tests.

```bash
cd ~/bonita-tests/poc # Open scripts directory
bash ./run-bundle.sh # Executes set of tests
```

You will be prompted to enter the target URL and session ID.

• • • 
