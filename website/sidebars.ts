import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'getting-started/installation',
        'getting-started/quickstart',
      ],
    },
    {
      type: 'category',
      label: 'Guides',
      items: [
        'guides/commands',
        'guides/script-editing',
        'guides/lsp-features',
        'guides/kindling',
      ],
    },
    {
      type: 'category',
      label: 'Configuration',
      items: [
        'configuration/options',
      ],
    },
    'credits',
  ],
};

export default sidebars;
