# Description

The `Connect2` R package implements ...

# Development 

Quelques notes pour développement du package: 
- Il est pratique de charger les packages [`devtools`](https://devtools.r-lib.org/) et [`usethis`](https://usethis.r-lib.org/) 
- Toutes les scripts doivent se trouver dans le dossier `R/`
- Les données doivent être dans le dossier `data/` au format `.RData` 
- Pour ajouter une dépendance à un autre package, e.g. `vegan`, utiliser la fonction `usethis::use_package(vegan)` 
- Les fonctions peuvent être documentées grâce au package [`roxygen2`](https://roxygen2.r-lib.org/): c'est ce qu'on voir quand on utilise `help(function_name)`. Pour un exemple de comment écrire au format roxygen, voir le script `R/data_formatting`. Pour plus de détails sur Roxygen, voir [ce guide d'utilisation](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html). 
- Pour charger les fonctions déjà écrites au fur et à mesure dans votre environnement de travail, simplement utiliser `devtools::load_all()`. 
- Au fur et à mesure du développement du package, un exemple d'utilisation pour le Plateau Mont-Royal peut être construit en mofifiant `vignettes/Plateau-Mont-Royal.Rmd`

# Installation 

Because `Connect2` is a private Habitat repository, you will need to set up a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token), and use the [`auth_token` argument](https://www.rdocumentation.org/packages/devtools/versions/1.13.6/topics/install_github) in the `devtools::install_github` function: 

```r
#install_packages("devtools")
library(devtools)
install_github("https://github.com/Habitat-RD/2022_HAB_Connect2", auth_token = "paste_your_token_here", build_vignettes = TRUE)
library(Connect2)
```

# Basic usage

This section, if applicable, shows a simple use case. 

## Input / Data

This section describe the type of data needed to run the analysis, and where to find the data if applicable.

## Additional resources

Link to the documentation and additional resources. 

# Contributors and corresponding author

List the contributors and the person that should be contacted in priority if users have a question about the project. 

# References

List the relevant litterature.

# Related project 

List the related Habitat project (e.g. project that have used this workflow)
