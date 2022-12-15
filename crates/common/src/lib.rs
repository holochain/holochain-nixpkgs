/// Git helper that requires the `git` shell command.
pub mod git_helper {
    use anyhow::bail;
    use std::io::BufRead;

    /// wrapper around "git ls-remote --tags --refs <glob>" that returns remote tags that pass through given glob filter pattern.
    pub async fn ls_remote_tags(url: &str, glob_filter: &str) -> anyhow::Result<Vec<String>> {
        let mut cmd = std::process::Command::new("git");
        cmd.args(&["ls-remote", "--tags", "--refs", url, glob_filter]);

        let output = cmd.output()?;

        if !output.status.success() {
            bail!("running {:#?} failed:\n{:#?}", cmd, output);
        }

        // looks something like this
        // 6535292238dc1fbd2b60433a2054f7787e4f060e	refs/tags/holochain-0.0.102
        // (...)
        // c77901e614e653adaa17e80b41db67f8a4fa5b88	refs/tags/holochain-0.0.127
        let lines = output
            .stdout
            .lines()
            .filter_map(|l| l.ok())
            .filter_map(|l| -> Option<String> {
                l.split("\t")
                    .last()
                    .map(|s| s.replace("refs/tags/", "").to_string())
            })
            .collect();

        Ok(lines)
    }

    /// wrapper around "git diff --quiet" that returns true if the given pathspec changed in the working directory.
    pub async fn pathspec_has_diff(pathspec: &str) -> anyhow::Result<bool> {
        let mut cmd = std::process::Command::new("git");
        cmd.args(&["diff", "--quiet", "--", pathspec]);

        let output = cmd.output()?;

        match output
            .status
            .code()
            .ok_or_else(|| anyhow::anyhow!("cmd exited without a status code"))?
        {
            0 => Ok(false),
            1 => Ok(true),
            _ => {
                bail!("running {:#?} failed:\n{:#?}", cmd, output);
            }
        }
    }
}
