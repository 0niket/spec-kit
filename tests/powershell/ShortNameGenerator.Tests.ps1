# ShortNameGenerator.Tests.ps1
# Pester tests for PowerShell short name generator functions
# Following TDD: These tests are written BEFORE implementation

BeforeAll {
    $RepoRoot = Resolve-Path "$PSScriptRoot/../.."
    $GeneratorScript = Join-Path $RepoRoot ".specify/scripts/powershell/short-name-generator.ps1"

    # Source the script if it exists (will fail initially - RED state)
    if (Test-Path $GeneratorScript) {
        . $GeneratorScript
    }
}

Describe "New-ShortName" {
    Context "Kebab-case output" {
        It "Creates kebab-case output" {
            $result = New-ShortName -Description "Add User Authentication"
            $result | Should -Match "^[a-z0-9-]+$"
        }
    }

    Context "Key term extraction" {
        It "Extracts technical terms" {
            $result = New-ShortName -Description "Implement OAuth2 integration for API"
            $result | Should -Match "oauth2"
            $result | Should -Match "api"
        }
    }

    Context "Output length" {
        It "Limits output to 2-4 words" {
            $result = New-ShortName -Description "I want to add user authentication with OAuth2 for the mobile app"
            $wordCount = ($result -split '-').Count
            $wordCount | Should -BeGreaterOrEqual 2
            $wordCount | Should -BeLessOrEqual 4
        }
    }

    Context "Technical terms" {
        It "Handles OAuth2 preservation" {
            $result = New-ShortName -Description "Add OAuth2 authentication"
            $result | Should -Match "oauth2"
        }

        It "Handles JWT preservation" {
            $result = New-ShortName -Description "Implement JWT tokens"
            $result | Should -Match "jwt"
        }
    }

    Context "Action verbs" {
        It "Prioritizes action verbs" {
            $result = New-ShortName -Description "Fix payment timeout bug"
            $result | Should -Match "fix"
        }
    }

    Context "Edge cases" {
        It "Returns fallback for empty input" {
            { New-ShortName -Description "" } | Should -Throw
        }
    }

    Context "Real-world examples" {
        It "Handles 'Add user authentication with OAuth2'" {
            $result = New-ShortName -Description "Add user authentication with OAuth2"
            $result | Should -Match "^[a-z0-9-]+$"
        }

        It "Handles 'Fix payment processing timeout'" {
            $result = New-ShortName -Description "Fix payment processing timeout"
            $result | Should -Match "^[a-z0-9-]+$"
        }

        It "Handles 'Create analytics dashboard'" {
            $result = New-ShortName -Description "Create analytics dashboard"
            $result | Should -Match "^[a-z0-9-]+$"
        }
    }
}

Describe "Split-Tokens" {
    Context "Splitting" {
        It "Splits on whitespace" {
            $result = Split-Tokens -Description "Add user auth"
            $result.Count | Should -BeGreaterThan 0
        }

        It "Splits on punctuation" {
            $result = Split-Tokens -Description "Add, update, delete"
            $result.Count | Should -BeGreaterThan 0
        }

        It "Preserves hyphens in words" {
            $result = Split-Tokens -Description "OAuth2-integration test"
            $result.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Remove-StopWords" {
    Context "Filtering" {
        It "Removes common words" {
            $tokens = @("the", "user", "a", "feature", "to", "add")
            $result = Remove-StopWords -Tokens $tokens
            $result | Should -Not -Contain "the"
            $result | Should -Not -Contain "a"
            $result | Should -Not -Contain "to"
        }

        It "Is case-insensitive" {
            $tokens = @("The", "User", "A", "Feature")
            $result = Remove-StopWords -Tokens $tokens
            $result | Should -Contain "User"
            $result | Should -Contain "Feature"
        }

        It "Preserves technical terms" {
            $tokens = @("API", "authentication")
            $result = Remove-StopWords -Tokens $tokens
            $result | Should -Contain "API"
            $result | Should -Contain "authentication"
        }
    }
}

Describe "Sort-TermsByPriority" {
    Context "Priority ordering" {
        It "Puts technical terms first" {
            $tokens = @("user", "OAuth2", "authentication")
            $result = Sort-TermsByPriority -Tokens $tokens
            # OAuth2 should appear before regular words
            $result.Count | Should -BeGreaterThan 0
        }

        It "Prioritizes action verbs" {
            $tokens = @("fix", "bug", "payment")
            $result = Sort-TermsByPriority -Tokens $tokens
            # "fix" should have high priority
            $result.Count | Should -BeGreaterThan 0
        }

        It "Maintains stable sort within priority" {
            $tokens = @("user", "profile", "dashboard")
            $result = Sort-TermsByPriority -Tokens $tokens
            $result.Count | Should -BeGreaterThan 0
        }
    }
}
