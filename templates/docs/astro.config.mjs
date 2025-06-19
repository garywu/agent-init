import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  // Update these values for your project
  site: 'https://yourusername.github.io',
  base: '/your-repo-name',
  output: 'static',
  integrations: [
    starlight({
      title: 'Project Documentation',
      description: 'Comprehensive documentation for your project',
      social: [
        {
          label: 'GitHub',
          icon: 'github',
          href: 'https://github.com/yourusername/your-repo',
        },
      ],
      sidebar: [
        {
          label: 'Getting Started',
          autogenerate: { directory: 'guides' },
        },
        {
          label: 'Reference',
          autogenerate: { directory: 'reference' },
        },
      ],
      customCss: [
        './src/styles/custom.css',
      ],
    }),
  ],
});