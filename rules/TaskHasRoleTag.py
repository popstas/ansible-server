import ansiblelint.utils
from ansiblelint import AnsibleLintRule

class TaskHasRoleTag(AnsibleLintRule):
    id = 'ANSIBLE0008'
    shortdesc = 'Tasks must have role tag'
    description = 'Tasks must have role tag'
    tags = ['productivity']


    def matchtask(self, file, task):
        # The meta files don't have tags
        if file['type'] in ["meta", "playbooks", ""]:
            return False

        if isinstance(task, basestring):
            return False

        # If the task include another task or make the playbook fail
        # Don't force to have a tag
        if not set(task.keys()).isdisjoint(['include','fail']):
            return False

        task_directory = file['path'].split('/')[-2]
        if task_directory not in ['tasks']:
            return False

        role_directory_name = file['path'].split('/')[-3]
        role_name = role_directory_name.replace('ansible-role-', '')

        # Task should have tags
        if not task.has_key('tags'):
            return '%s \'%s\'' % (self.shortdesc, role_name)
        else:
            if role_name not in task['tags']:
                return '%s \'%s\', task tags: %s' % (self.shortdesc, role_name, task['tags'])

        return False