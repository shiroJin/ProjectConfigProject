import git

def checkout_branch(repo, branch_name, create=False, tag_name=None):
  for ref in repo.branches:
    if ref.name == branch_name:
      ref.checkout()
      return

  for ref in repo.remote().refs:
    if ref.remote_head == branch_name:
      repo.git().checkout(ref, b=ref.remote_head)
      return
  
  if create and tag_name:
    for tag in repo.tags:
      if tag.name == tagName:
        repo.create_head(branch_name, tag.commit)
        return
  
  raise('checkout branch error')
