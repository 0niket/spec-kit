# InteractivePrompts.Tests.ps1
# Pester tests for PowerShell interactive prompt functions
# Following TDD: These tests are written BEFORE implementation

BeforeAll {
    $RepoRoot = Resolve-Path "$PSScriptRoot/../.."
    $PromptsScript = Join-Path $RepoRoot ".specify/scripts/powershell/interactive-prompts.ps1"

    # Source the script if it exists (will fail initially - RED state)
    if (Test-Path $PromptsScript) {
        . $PromptsScript
    }
}

Describe "Prompt-TicketId" {
    Context "Valid ticket ID input" {
        It "Returns valid ticket ID" {
            # Mock Read-Host to simulate user input
            Mock Read-Host { return "abc123xy" }

            $result = Prompt-TicketId
            $result | Should -Be "abc123xy"
        }
    }

    Context "Skip keywords" {
        It "Recognizes 'skip' keyword" {
            Mock Read-Host { return "skip" }

            $result = Prompt-TicketId
            $result | Should -Be "SKIP"
        }

        It "Recognizes 'none' keyword" {
            Mock Read-Host { return "none" }

            $result = Prompt-TicketId
            $result | Should -Be "SKIP"
        }

        It "Recognizes 'n' keyword" {
            Mock Read-Host { return "n" }

            $result = Prompt-TicketId
            $result | Should -Be "SKIP"
        }
    }

    Context "Validation" {
        It "Validates ticket ID format" {
            Mock Read-Host { return "PROJECT-123" }

            $result = Prompt-TicketId
            $result | Should -Match "^[a-zA-Z0-9-]+$"
        }

        It "Handles invalid format with retry loop" {
            # First invalid, then valid
            $script:callCount = 0
            Mock Read-Host {
                $script:callCount++
                if ($script:callCount -eq 1) { return "abc@123" }
                return "abc123"
            }
            Mock Write-Host { }  # Suppress error messages

            $result = Prompt-TicketId
            $result | Should -Match "^[a-zA-Z0-9-]+$"
        }
    }
}

Describe "Prompt-ShortName" {
    Context "Suggestion acceptance" {
        It "Accepts suggestion on empty input" {
            Mock Read-Host { return "" }
            Mock Write-Host { }  # Suppress suggestion message

            $result = Prompt-ShortName -Suggestion "oauth2-user-auth"
            $result | Should -Be "oauth2-user-auth"
        }
    }

    Context "Custom name" {
        It "Accepts custom name" {
            Mock Read-Host { return "my-custom-name" }
            Mock Write-Host { }

            $result = Prompt-ShortName -Suggestion "oauth2-user-auth"
            $result | Should -Be "my-custom-name"
        }
    }

    Context "Format validation" {
        It "Accepts valid format (alphanumeric + hyphens)" {
            Mock Read-Host { return "valid-name-123" }
            Mock Write-Host { }

            $result = Prompt-ShortName -Suggestion "suggestion"
            $result | Should -Be "valid-name-123"
        }

        It "Rejects invalid format" {
            $script:callCount = 0
            Mock Read-Host {
                $script:callCount++
                if ($script:callCount -eq 1) { return "invalid name!" }
                return "valid-name"
            }
            Mock Write-Host { }

            $result = Prompt-ShortName -Suggestion "suggestion"
            $result | Should -Be "valid-name"
        }
    }
}

Describe "Test-Cancellation" {
    Context "Cancel keywords" {
        It "Recognizes 'cancel' keyword" {
            { Test-Cancellation -Input "cancel" } | Should -Throw
        }

        It "Recognizes 'quit' keyword" {
            { Test-Cancellation -Input "quit" } | Should -Throw
        }

        It "Recognizes 'exit' keyword" {
            { Test-Cancellation -Input "exit" } | Should -Throw
        }

        It "Recognizes 'abort' keyword" {
            { Test-Cancellation -Input "abort" } | Should -Throw
        }
    }

    Context "Case insensitivity" {
        It "Recognizes 'CANCEL' (uppercase)" {
            { Test-Cancellation -Input "CANCEL" } | Should -Throw
        }

        It "Recognizes 'Quit' (mixed case)" {
            { Test-Cancellation -Input "Quit" } | Should -Throw
        }
    }

    Context "Normal input" {
        It "Returns without throwing for normal input" {
            { Test-Cancellation -Input "abc123" } | Should -Not -Throw
        }

        It "Returns without throwing for feature names" {
            { Test-Cancellation -Input "my-feature" } | Should -Not -Throw
        }
    }
}

Describe "Remove-InvalidCharacters" {
    Context "Character removal" {
        It "Removes special characters" {
            $result = Remove-InvalidCharacters -Input "abc@123#xyz"
            $result | Should -Be "abc123xyz"
        }
    }

    Context "Preservation" {
        It "Preserves hyphens" {
            $result = Remove-InvalidCharacters -Input "abc-123-xyz"
            $result | Should -Be "abc-123-xyz"
        }

        It "Preserves alphanumeric characters" {
            $result = Remove-InvalidCharacters -Input "Project123"
            $result | Should -Be "Project123"
        }
    }

    Context "Edge cases" {
        It "Handles empty input" {
            $result = Remove-InvalidCharacters -Input ""
            $result | Should -Be ""
        }
    }
}
