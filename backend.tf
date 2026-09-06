terraform {
  backend "azurerm" {
    key              = "terraform/azure-validation.tfstate"
    use_azuread_auth = true
  }
}
