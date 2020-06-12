# Sdkman Bash Completion

This is a standard bash completion file to provide completions for the [sdkman](https://sdkman.io) tool

## Installation

```
    cd ~/.config/
    git clone https://github.com/liviu-vasut/sdkman-bash-completion.git
    echo ". ~/.config/sdkman-bash-completion/sdk-completion.bash" >> ~/.bash_completion
    . ~/.bash_completion
```

## Dependencies
The completion script uses only tools that should already be available on your system
- sdkman
- find
- sed
- cat
- cut

## Usage
To improve speed, the script maintains a cache with the candidates and versions of the SDKs managed by *sdkman*. The cache expires every 7 days. To configure the expiration time either set an environment variable named `SDKMAN_CACHE_EXPIRE_DAYS` or change the value of `cache_expire_days` in `~/.config/sdkman-bash-completion/sdk-completion.bash` directly.
