use std::sync::{Mutex, MutexGuard};

use itertools::Itertools;
use log::trace;
use once_cell::sync::OnceCell;

static CRATES_IO_INDEX: OnceCell<Mutex<crates_index::Index>> = OnceCell::new();

/// Convenience wrapper around Result
pub type Fallible<T> = anyhow::Result<T>;

/// retrieves the statically saved index with the option to force an update.
pub fn index(update: bool) -> Fallible<MutexGuard<'static, crates_index::Index>> {
    let first_run = CRATES_IO_INDEX.get().is_none();

    let crates_io_index = CRATES_IO_INDEX.get_or_try_init(|| -> Fallible<_> {
        let mut index = crates_index::Index::new_cargo_default()?;
        trace!("Using crates index at {:?}", index.path());

        index.update()?;

        Ok(Mutex::new(index))
    })?;

    if !first_run && update {
        crates_io_index
            .lock()
            .map_err(|e| anyhow::anyhow!("failed to lock the index: {}", e))?
            .update()?;
    }

    let index_lock = crates_io_index
        .lock()
        .map_err(|e| anyhow::anyhow!("failed to lock the index: {}", e))?;

    Ok(index_lock)
}

/// checks if a given crate version is published
pub fn is_version_published(
    crt_name: &str,
    crt_version: &semver::Version,
    update: bool,
) -> Fallible<bool> {
    let index_lock = crate::index(update)?;

    if let Some(crt) = index_lock.crate_(crt_name) {
        let versions: Vec<semver::Version> = crt
            .versions()
            .into_iter()
            .map(|version| -> Fallible<_> {
                semver::Version::parse(version.version()).map_err(anyhow::Error::from)
            })
            .try_collect()?;

        Ok(versions.into_iter().any(|version| &version == crt_version))
    } else {
        Ok(false)
    }
}
