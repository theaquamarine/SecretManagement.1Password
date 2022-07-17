# This assumes 1Password is already registered and unlocked
# TODO: Vault is manually specified for all tests to avoid https://github.com/cdhunt/SecretManagement.1Password/issues/16

BeforeAll {
	$testDetails = @{
		Vault        = 'Personal'
		LoginName    = 'TestLogin' + (Get-Random -Maximum 99999)
		PasswordName = 'TestPassword' + (Get-Random -Maximum 99999)
		UserName     = 'TestUserName'
		Password     = 'TestPassword'
	}
}

Describe 'It gets login info with vault specified' {
	BeforeAll {
		# Create the login, if it doesn't already exist.
		# TODO: currently also creates if >1 exists
		$item = & op get item $testDetails.LoginName --fields title --vault $testDetails.Vault 2>$null
		if ($null -eq $item) {
			& op create item login --title $testDetails.LoginName "username=$($testDetails.UserName)" "password=$($testDetails.Password)"
			$createdLogin = $true
		} else {
			Write-Warning "An item called $($testDetails.LoginName) already exists"
		}
	}

	It 'returns logins as PSCredentials' -Skip {
		# TODO: https://github.com/cdhunt/SecretManagement.1Password/issues/8
		$info = Get-SecretInfo -Vault $testDetails.Vault -Name $testDetails.LoginName
		$info | Should -BeOfType [Microsoft.PowerShell.SecretManagement.SecretInformation]
		$info.Type | Should -Be PSCredential
	}

	AfterAll {
		if ($createdLogin) {& op delete item $testDetails.LoginName}
	}
}

Describe 'It gets password info with vault specified' {
	BeforeAll {
		# Create the password, if it doesn't already exist.
		# TODO: currently also creates if >1 exists
		$item = & op get item $testDetails.PasswordName --fields title --vault $testDetails.Vault 2>$null
		if ($null -eq $item) {
			& op create item password --title $testDetails.PasswordName "password=$($testDetails.Password)"
			$createdPassword = $true
		} else {
			Write-Warning "An item called $($testDetails.PasswordName) already exists"
		}
	}

	It 'returns passwords as SecureStrings' -Skip {
		# TODO: https://github.com/cdhunt/SecretManagement.1Password/issues/8
		$info = Get-SecretInfo -Vault $testDetails.Vault -Name $testDetails.PasswordName
		$info | Should -BeOfType [Microsoft.PowerShell.SecretManagement.SecretInformation]
		$info.Type | Should -Be SecureString
	}

	AfterAll {
		if ($createdPassword) {& op delete item $testDetails.PasswordName}
	}
}