import * as React from 'react';

import { iconMeta, iconPaths, type IconName } from './icons.g';
import { iconSize } from '../tokens/tokens.g';

export type SsIconSize = keyof typeof iconSize | number;

export interface SsIconProps extends Omit<React.SVGProps<SVGSVGElement>, 'name'> {
  /** Icon from the Surplus → Served set. */
  name: IconName;
  /** Token name (`xs`…`xl`) or an explicit pixel value. Defaults to `md` (24). */
  size?: SsIconSize;
  /** Filled variants are for active states and primary actions (§05.4). */
  filled?: boolean;
  /**
   * Accessible label. Omit for decorative icons that sit beside a text label —
   * the icon is then hidden from screen readers rather than announced twice.
   */
  title?: string;
}

const resolveSize = (size: SsIconSize): number =>
  typeof size === 'number' ? size : iconSize[size];

/**
 * Renders an icon from the shared geometry source.
 *
 * The 24-unit canvas scales to `size`, so the 2px stroke scales with it —
 * §05.6's "maintains visual weight", rather than a hairline at 48px.
 *
 * ```tsx
 * <SsIcon name="leaf" />
 * <SsIcon name="home" filled size="lg" />
 * <SsIcon name="phone" title="Call the donor" />
 * ```
 */
export const SsIcon = React.forwardRef<SVGSVGElement, SsIconProps>(function SsIcon(
  { name, size = 'md', filled = false, title, ...rest },
  ref,
) {
  const def = iconPaths[name];
  const px = resolveSize(size);
  const useFilled = filled && 'filled' in def;
  const paths = (useFilled ? (def as { filled: readonly string[] }).filled : def.outline);

  // A filled icon must be ONE <path>: fill-rule only applies within a single
  // path, so a hole drawn as a separate element would just fill solid.
  const d = useFilled ? paths.join(' ') : null;

  const paintProps = useFilled
    ? {
        fill: 'currentColor',
        fillRule: ('fillRule' in def ? def.fillRule : 'evenodd') as 'evenodd' | 'nonzero',
      }
    : {
        fill: 'none',
        stroke: 'currentColor',
        strokeWidth: iconMeta.strokeWidth,
        strokeLinecap: 'round' as const,
        strokeLinejoin: 'round' as const,
      };

  return (
    <svg
      ref={ref}
      xmlns="http://www.w3.org/2000/svg"
      viewBox={`0 0 ${iconMeta.viewBox} ${iconMeta.viewBox}`}
      width={px}
      height={px}
      role={title ? 'img' : undefined}
      aria-hidden={title ? undefined : true}
      focusable="false"
      {...paintProps}
      {...rest}
    >
      {title ? <title>{title}</title> : null}
      {d !== null ? <path d={d} /> : paths.map((p, i) => <path key={i} d={p} />)}
    </svg>
  );
});

export type { IconName };
export { iconNames, coreIconNames } from './icons.g';
