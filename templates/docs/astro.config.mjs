import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  // ⚠️ CRITICAL: Update these values for your project!
  // Without correct values, styles and links will be broken in production
  site: 'https://yourusername.github.io',  // Replace 'yourusername' with your GitHub username
  base: '/your-repo-name',                  // Replace with exact repository name (case-sensitive!)
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