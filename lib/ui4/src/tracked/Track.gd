class_name Track

static func value(val: Variant) -> TrackedValue: return TrackedValue.new(val)

static func array(val: Array) -> TrackedArray: return TrackedArray.new(val)

static func container_index(tracked: TrackedContainer, key) -> TrackedContainerItem:
    return TrackedContainerItem.new(tracked, key)

static func container_value(tracked: TrackedContainer, key) -> TrackedMap:
    return map(container_index(tracked, key), func(i): if i >= 0: tracked.value_at(i))

static func map(tracked: Tracked, transform: Callable) -> TrackedMap:
    return TrackedMap.new(tracked, transform)

static func combine(tracked: Array[Tracked]) -> TrackedCombine:
    return TrackedCombine.new(tracked)

# TODO: consider spread
static func combine_map(tracked: Array[Tracked], transform: Callable) -> TrackedMap:
    return map(combine(tracked), Fn.spread(transform))

static func transform(tracked: TrackedArrayBase, transform: Callable) -> TrackedTransform:
    return TrackedTransform.new(tracked, transform)

static func buffer(tracked: Tracked, amount: int) -> TrackedBuffer:
    return TrackedBuffer.new(tracked, amount)

static func dedup(tracked: Tracked) -> TrackedDedup:
    return TrackedDedup.new(tracked)

static func map_dedup(tracked: Tracked, transform: Callable) -> TrackedDedup:
    return dedup(map(tracked, transform))

static func value_dedup(val: Variant) -> TrackedDedup: return dedup(TrackedValue.new(val))

static func tween(target: Tracked, duration: float) -> TrackedTween:
    return TrackedTween.new(target, duration)

static func lens(tracked: Tracked, prop: String) -> TrackedLens:
    return TrackedLens.new(tracked, prop)

static func inner(tracked: Tracked) -> TrackedInner:
    assert(tracked.value() is Tracked)
    return TrackedInner.new(tracked)
