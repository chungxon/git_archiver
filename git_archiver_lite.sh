# Simple script to archive a git repository
git archive -o release.zip HEAD
git submodule --quiet foreach 'cd $toplevel; zip -ru release.zip $sm_path'
